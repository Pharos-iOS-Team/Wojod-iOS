// Copyright © 2021 Pharos Solutions. All rights reserved.
// swiftlint:disable all

import AVKit
import AVFoundation
import DZNEmptyDataSet
import HandySwift
import JGProgressHUD
import UIKit
import SafariServices
import VdoCipherKit
import Photos

internal enum CourseState {
    case normal
    case pending
    case booked
}

internal enum ActiveScreen {
    case details
    case reviews
    case materials
}

internal enum MaterialsSections: Int, CaseIterable {
    case assignments
    case quizzes
    case videos
    case documents
}

protocol LoadableView: AnyObject {
    func startLoading()
    func stopLoading()
}

class CourseDetailsViewController: UIViewController {
    @IBOutlet private var vdoPlayerView: VdoPlayerView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var actionButton: UIButton! {
        didSet {
            actionButton.layer.cornerRadius = UIConstants.cornerRadius
            actionButton.setTitle(L10n.CourseDetails.Main.bookNow)
        }
    }

    // MARK: - Private Properties

    private var player: AVPlayer?
    private var state: CourseState?
    private var activeScreen: ActiveScreen?
    private var viewModel: CourseDetailsViewModel?
    private var quizzesViewModel: AssessmentsOverViewViewModel?
    private var assignemntsViewModel: AssessmentsOverViewViewModel?
    private var lessonsList: [Lesson] = []
    private var lessonNumbersList: [Int]?
    private var reviewsList: [Review]?
    private var attachmentsOfLessons: [Int: LessonAttachmentsModel] = [:]
    private var expandedSections: [Int] = []
    private var blurredView: UIVisualEffectView?
    private let detailsRowHeight: CGFloat = 65
    private let reviewsRowHeight: CGFloat = 90
    private var materials: Materials!
    private var documentInteractionController = UIDocumentInteractionController()
    private var loadingHud: JGProgressHUD?
    private var allAttachmentsOfLesson: [Any] = []
    private var alertViewController: AppAlertViewController?
    private var selectedAssessment: Assessment?
    private var selectedAssessmentSection: Int?
    private var timer = Timer()
    private var updateId: Int = .zero
    private var videoId: String = ""
    private var avPlayerController = AVPlayerViewController()
    private let refreshControl = UIRefreshControl()

    private var doesLessonContainAttachments: [Int: Bool] = [:]
    private var activeSubscreen: CourseDetailsActiveSubScreen = .details

    // MARK: - Public Properties

    var course: Course?
    var teacherName: String?
    var teacherID: Int?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        state = getReservationState()
        activeScreen = .details
        viewModel = CourseDetailsViewModel()
        quizzesViewModel = AssessmentsOverViewViewModel(module: .quizzes)
        assignemntsViewModel = AssessmentsOverViewViewModel(module: .assignments)
        configureActionButtonAccordingToState()
        loadCourseLessons()
        configureTableView()
        documentInteractionController.delegate = self
        bindStartAssessmentHandler()
        bindAssessmentResultsHandler()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        configureRefreshControl()
        observeInternetConnection()
        showQuizAlert()
        setHeader()
    }

    private func setHeader() {
        let detailsView = CourseDetailsInfoHeaderView()
        detailsView.configure(
            model: CourseDetailsInfoModel(
                courseTitle: course?.name,
                teacherName: teacherName,
                image: course?.media?.fileUrl,
                video: course?.video,
                description: course?.summary,
                price: coursePrice(),
                numberOfReviews: String(course?.reviewsCount ?? .zero),
                rating: course?.rating,
                shouldHideMaterials: state != .booked,
                buttonSelected: activeScreen ?? .details,
                state: state ?? .normal,
                lessonsUnreadCount: course?.lessonsUnreadCount,
                materialsUnreadCount: course?.materialsUnreadCount,
                delegate: self
            )
        )
        tableView.tableHeaderView = detailsView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.autoResizeTableHeaderView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

        if activeScreen == .materials {
            guard let courseID = course?.id else { return }
            showLoadingIndicator()
            viewModel?.loadMaterials(courseID: courseID) { materials in
                self.hideLoadingIndicator()
                self.materials = materials
                self.tableView.reloadData()
            }
        } else if activeScreen == .details {
            loadCourseLessons()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        expandedSections.removeAll()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayerController.view.layer.sublayers?.forEach { layer in
            if layer.isKind(of: CATextLayer.self) {
                layer.removeFromSuperlayer()
            }
        }
    }

    // MARK: - IBActions

    @IBAction private func didTapOnActionButton(_ sender: UIButton) {
        switch state {
        case .normal:
            viewModel?.bookCourses(courseID: course?.id ?? 0) { bookingResponse, error in
                if error == nil {
                    self.state = .pending
                    self.actionButton.setTitle(L10n.CourseDetails.Main.cancelBooking)
                    self.blurView()
                    self.displayReceipt(bookingResponse!, coursePrice: self.course?.price ?? "")
                } else if let error = error as? WJError {
                    self.showAlert(imageName: Images.danger.name, title: "Error", message: error.message)
                }
            }

        case .pending:
            self.blurView()
            self.displayConfirmCancelBooking()

        case .booked:
            self.blurView()
            self.displayReviewCoursePopup()

        default:
            return
        }
    }
    // MARK: - Private Functions
    private func coursePrice() -> String {
        if course?.price == nil || course?.price?.isEmpty ?? true {
            return L10n.Home.Course.returnToTeacher
        } else {
            return "\(L10n.Home.Course.price) \(course?.price ?? "")"
        }
    }

    private func getReservationState() -> CourseState {
        switch course?.reservationState {
        case "pending":
            return .pending
        case "approved":
            return .booked
        default:
            return .normal
        }
    }

    private func handleAttachmentsExpantion(section: Int) {
        if course?.reservationState == "approved" {
            if expandedSections.contains(section) {
                if let index = expandedSections.firstIndex(of: section) {
                    expandedSections.remove(at: index)
                }
                self.attachmentsOfLessons[section] = nil
                self.tableView.reloadData()
            } else {
                expandedSections.append(section)
                viewModel?.loadAttachmentsOfLesson(lessonID: lessonsList[section].id) { attachmentsModel in
                    self.attachmentsOfLessons[section] = attachmentsModel
                    if   self.attachmentsOfLessons[section]?.assignments?.isEmpty ?? true &&
                            self.attachmentsOfLessons[section]?.documents?.isEmpty ?? true &&
                            self.attachmentsOfLessons[section]?.quizzes?.isEmpty ?? true &&
                            self.attachmentsOfLessons[section]?.videos?.isEmpty ?? true {
                        self.doesLessonContainAttachments[section] = false
                    } else {
                        self.doesLessonContainAttachments[section] = true
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

    @objc
    private func handlePlusButtonAppearance(section: Int) {
        if course?.reservationState == "approved" {
            viewModel?.loadAttachmentsOfLesson(lessonID: lessonsList[section].id) { attachmentsModel in
                self.attachmentsOfLessons[section] = attachmentsModel
                if self.attachmentsOfLessons[section]?.assignments?.isEmpty ?? true &&
                    self.attachmentsOfLessons[section]?.documents?.isEmpty ?? true &&
                    self.attachmentsOfLessons[section]?.quizzes?.isEmpty ?? true &&
                    self.attachmentsOfLessons[section]?.videos?.isEmpty ?? true {
                    self.doesLessonContainAttachments[section] = false
                    self.attachmentsOfLessons[section] = nil
                } else {
                    self.doesLessonContainAttachments[section] = true
                    self.attachmentsOfLessons[section] = nil
                }
                self.tableView.reloadData()
            }
        }
    }

    private func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }

    private func configureActionButtonAccordingToState() {
        switch state {
        case .normal:
            actionButton.setTitle(L10n.CourseDetails.Main.bookNow)
        case .pending:
            actionButton.setTitle(L10n.CourseDetails.Main.cancelBooking)
        case .booked:
            actionButton.setTitle(L10n.CourseDetails.Main.reviewCourse)
        default:
            return
        }
    }

    private func blurView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        self.view.addSubview(blurredView ?? blurEffectView)
    }

    private func displayReceipt(_ receiptData: BookingCourseResponseModel, coursePrice: String) {
        let view = UINib(nibName: "ReceiptView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ReceiptView
        view?.center = CGPoint(
            x: self.view.frame.size.width / 2,
            y: self.view.frame.size.height / 2
        )
        view?.configure(with: receiptData, coursePrice: coursePrice)
        view?.receiptDoneButtonDelegate = self
        view?.addShadow()
        self.view.addSubview(view ?? UIView())
    }

    private func displayConfirmCancelBooking() {
        let view = UINib(nibName: "CancelBookingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? CancelBookingView
        view?.layer.cornerRadius = UIConstants.cornerRadius
        view?.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        view?.delegate = self
        view?.addShadow()
        self.view.addSubview(view ?? UIView())
    }

    private func displayReviewCoursePopup() {
        let reviewCourseView = UINib(nibName: "ReviewCourseView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ReviewCourseView
        reviewCourseView?.layer.cornerRadius = UIConstants.cornerRadius
        reviewCourseView?.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        reviewCourseView?.delegate = self
        reviewCourseView?.addShadow()
        self.view.addSubview(reviewCourseView ?? UIView())
    }

    private func configureTableView() {
        tableView.registerCell(ofType: AttachmentTableViewCell.self)
        tableView.registerCell(ofType: ReviewTableViewCell.self)
        tableView.registerCell(ofType: MaterialTableViewCell.self)
        tableView.registerHeaderFooterView(ofType: CourseDetailsHeaderView.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }

    private func loadCourseLessons() {
        viewModel?.loadLessons(courseID: course?.id ?? 0) { lessonsModel in
            self.lessonsList = lessonsModel.lessons
            self.generateLessonsNumbersList()
            self.lessonNumbersList?.forEach { self.handlePlusButtonAppearance(section: $0 - 1) }
        }
    }

    private func generateLessonsNumbersList() {
        guard lessonsList.count >= 1 else { return }
        lessonNumbersList = Array(1 ... lessonsList.count)
    }

    private func numberOfRowsInLessonSection(_ sectionNumber: Int) -> Int {
        let attachments = attachmentsOfLessons[sectionNumber - 1]
        let documentsCount = attachments?.documents?.count ?? 0
        let assignmentsCount = attachments?.assignments?.count ?? 0
        let videosCount = attachments?.videos?.count ?? 0
        let quizzesCount = attachments?.quizzes?.count ?? 0
        return documentsCount + assignmentsCount + videosCount + quizzesCount
    }

    private func configureAttachments(in section: Int) {
        allAttachmentsOfLesson.removeAll()
        let attachments = attachmentsOfLessons[section]
        if let assignments = attachments?.assignments {
            for assignment in assignments {
                allAttachmentsOfLesson.append(assignment)
            }
        }
        if let quizzes = attachments?.quizzes {
            for quiz in quizzes {
                allAttachmentsOfLesson.append(quiz)
            }
        }
        if let videos = attachments?.videos {
            for video in videos {
                allAttachmentsOfLesson.append(video)
            }
        }
        if let documents = attachments?.documents {
            for document in documents {
                allAttachmentsOfLesson.append(document)
            }
        }
    }

    private func configureLessonDetails(cell: AttachmentTableViewCell?, with attachment: Any) {
        if let assignment = attachment as? Assignment {
            cell?.setSubtitleLabel(assignment.title ?? "")
            cell?.setAttachmentImageView(Images.quiz.image)
        } else if let quiz = attachment as? Assessment {
            cell?.setSubtitleLabel(quiz.title ?? "")
            cell?.setAttachmentImageView(Images.quiz.image)
        } else if let video = attachment as? Video {
            cell?.setSubtitleLabel(video.title ?? "")
            if !(video.link?.isEmpty ?? true) {
                cell?.setAttachmentImageView(Images.link.image)
            } else {
                cell?.setAttachmentImageView(Images.videoExtension.image)
            }
        } else if let document = attachment as? MaterialsDocument {
            cell?.setSubtitleLabel((document.title ?? document.fileName) ?? "Document")
            let image = getCorrespondingImage(for: document)
            cell?.setAttachmentImageView(image)
        }
    }

    private func getCorrespondingImage(for document: MaterialsDocument?) -> UIImage {
        switch document?.contentType {
        case "application/pdf":
            return Images.pdfExtension.image
        case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
            return Images.excelExtension.image
        case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            return Images.wordExtension.image
        case "image/png", "image/jpeg", "image/jpg":
            return Images.imageExtension.image
        case "application/zip":
            return Images.zipExtension.image
        default:
            if document?.link != nil {
                return Images.link.image
            } else {
                return Images.unknownExtension.image
            }
        }
    }

    func storeAndShare(withURLString: String) {
        guard let url = URL(string: withURLString) else { return }
        showLoadingIndicator()
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "fileName.png")
            do {
                try data.write(to: tmpURL)
            } catch {
                AlertHandler(presentingViewCtrl: self).showConfirmAlert(
                    title: L10n.Global.Titles.error,
                    message: L10n.Global.Alerts.somethingWentWrong
                )
            }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                self.share(url: tmpURL)
            }
        }.resume()
    }

    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentPreview(animated: true)
    }

    private func startAssessment(for type: AssessmentType, at indexPath: IndexPath) {
        if activeScreen == .materials {
            guard let assessment = type == .quiz ? quizzesViewModel?.assessments[indexPath.row] : assignemntsViewModel?.assessments[indexPath.row]
            else { return }
            switch assessment.type {
            case "Quiz":
                showStartQuizAlert(assessment)
                let cell = tableView.cellForRow(at: indexPath) as? MaterialTableViewCell
                cell?.stopLoadingIndicator()
            default:
                tableView.isUserInteractionEnabled = false
                assignemntsViewModel?.startAssessment(with: assessment) { [weak self] in
                    self?.tableView.isUserInteractionEnabled = true
                    let cell = self?.tableView.cellForRow(at: indexPath) as? MaterialTableViewCell
                    cell?.stopLoadingIndicator()
                }
            }
        } else {
            let assessment = allAttachmentsOfLesson[indexPath.row]
            if let assignment = assessment as? Assessment, assignment.type != "Quiz" {
                tableView.isUserInteractionEnabled = false
                assignemntsViewModel?.startAssessment(with: assignment) { [weak self] in
                    self?.tableView.isUserInteractionEnabled = true
                }
            } else if let quiz = assessment as? Assessment, quiz.type == "Quiz" {
                showStartQuizAlert(quiz)
            }
        }
    }

    private func showStartQuizAlert(_ assessment: Assessment) {
        alertViewController = showAndReturnAlert(
            imageName: Asset.Images.danger.name,
            title: L10n.Quizzes.alertTitle,
            message: L10n.Quizzes.alertSubTitle,
            primaryButtonTitle: L10n.Quizzes.start,
            dismissButtonTitle: L10n.Global.Actions.cancel
        ) { [weak self] in
            self?.startAssessment(with: assessment)
        }
    }

    private func startAssessment(with assessment: Assessment) {
        alertViewController?.startPrimaryButtonLoading()
        if assessment.type == "Quiz" {
            quizzesViewModel?.startAssessment(with: assessment)
        } else {
            assignemntsViewModel?.startAssessment(with: assessment)
        }
    }

    private func showResultForRow(for type: String, at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? LoadableView
        tableView.isUserInteractionEnabled = false
        cell?.startLoading()
        if activeScreen == .materials {
            if type == "Quiz" {
                quizzesViewModel?.assessmentResults(for: quizzesViewModel?.assessments[indexPath.row]) { [weak self] in
                    self?.tableView.isUserInteractionEnabled = true
                    cell?.stopLoading()
                }
            } else {
                assignemntsViewModel?.assessmentResults(for: assignemntsViewModel?.assessments[indexPath.row]) { [weak self] in
                    self?.tableView.isUserInteractionEnabled = true
                    cell?.stopLoading()
                }
            }
        } else {
            if type == "Quiz" {
                let assessment = allAttachmentsOfLesson[indexPath.row] as? Assessment
                quizzesViewModel?.assessmentResults(for: assessment) { [weak self] in
                    self?.tableView.isUserInteractionEnabled = true
                    cell?.stopLoading()
                }
            } else {
                let assessment = allAttachmentsOfLesson[indexPath.row] as? Assessment
                assignemntsViewModel?.assessmentResults(for: assessment) { [weak self] in
                    self?.tableView.isUserInteractionEnabled = true
                    cell?.stopLoading()
                }
            }
        }
    }

    private func bindStartAssessmentHandler() {
        quizzesViewModel?.startAssessmentHandler = { [weak self] assessmentID, assessmentDetails, _ in
            self?.dismissAlertView { [weak self] in
                self?.alertViewController = nil
                self?.openAssessmentDetails(.quizzes, assessmentID, assessmentDetails)
            }
        }

        assignemntsViewModel?.startAssessmentHandler = { [weak self] assessmentID, assessmentDetails, _ in
            self?.openAssessmentDetails(.assignments, assessmentID, assessmentDetails)
        }
    }

    private func bindAssessmentResultsHandler() {
        quizzesViewModel?.assessmentResultsHandler = { [weak self] assessmentID, assessmentDetails, type in
            let module: AssessmentsOverViewViewModel.Module = type == .quiz
                ? .quizzes
                : .assignments
            self?.navigationController?.navigationBar.isHidden = false
            self?.navigationController?.pushViewController(
                AssessmentDetailsConfigurator.configure(
                    status: .closed,
                    module: module,
                    assessmentID: assessmentID,
                    assessmentDetails: assessmentDetails,
                    delegate: self
                ),
                animated: true
            )
        }

        assignemntsViewModel?.assessmentResultsHandler = { [weak self] assessmentID, assessmentDetails, type in
            let module: AssessmentsOverViewViewModel.Module = .assignments
            self?.navigationController?.navigationBar.isHidden = false
            self?.navigationController?.pushViewController(
                AssessmentDetailsConfigurator.configure(
                    status: .closed,
                    module: module,
                    assessmentID: assessmentID,
                    assessmentDetails: assessmentDetails,
                    delegate: self
                ),
                animated: true
            )
        }
    }

    private func openAssessmentDetails(_ currentModule: AssessmentsOverViewViewModel.Module, _ assessmentID: Int?, _ assessmentDetails: AssessmentDetails?) {
        let viewCtrl = AssessmentDetailsConfigurator.configure(
            status: .open,
            module: currentModule,
            assessmentID: assessmentID,
            assessmentDetails: assessmentDetails,
            delegate: self
        )
        navigationController?.navigationBar.isHidden = false
        navigationController?.pushViewController(viewCtrl, animated: true)
    }

    private func dismissAlertView(completion: (() -> Void)? = nil) {
        alertViewController?.dismiss(animated: true, completion: completion)
    }

    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc
    private func refresh(_ sender: AnyObject) {
        viewModel?.loadCourse(courseID: "\(course?.id ?? 0)") { course in
            self.course = course
            self.state = self.getReservationState()
            self.configureActionButtonAccordingToState()
            self.tableView.reloadData()
            self.handleRefreshingAccordingToOpenedTab()
        }
    }

    private func handleRefreshingAccordingToOpenedTab() {
        switch activeScreen {
        case .details:
            loadCourseLessons()
            tableView.refreshControl?.endRefreshing()

        case .materials:
            showLoadingIndicator()
            viewModel?.loadMaterials(courseID: course?.id ?? 0) { materials in
                self.hideLoadingIndicator()
                self.materials = materials
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }

        case .reviews:
            showLoadingIndicator()
            viewModel?.loadReviews(courseID: course?.id ?? 0) { result in
                self.hideLoadingIndicator()
                self.reviewsList = result.reviews
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }

        default:
            return
        }
    }
}

// MARK: - Table View Data Source

extension CourseDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch activeScreen {
        case .details:
            return lessonsList.count
        case .materials:
            return MaterialsSections.allCases.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activeScreen {
        case .reviews:
            return reviewsList?.count ?? .zero
        case .details:
            return numberOfRowsInLessonSection(section + 1)
        case .materials:
            switch MaterialsSections(rawValue: section) {
            case .assignments:
                return materials?.assignments?.count ?? 0
            case .quizzes:
                return materials?.quizzes?.count ?? 0
            case .videos:
                return materials?.videos?.count ?? 0
            case .documents:
                return materials?.documents?.count ?? 0
            default:
                return 0
            }
        default:
            return 0
        }
    }

    // swiftlint:disable function_body_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch activeScreen {
        case .details:
            configureAttachments(in: indexPath.section)
            let cell = tableView.dequeueCell(ofType: AttachmentTableViewCell.self, for: indexPath)
            let attachment = allAttachmentsOfLesson[indexPath.row]
            configureLessonDetails(cell: cell, with: attachment)
            return cell ?? UITableViewCell()

        case .reviews:
            let cell = tableView.dequeueCell(ofType: ReviewTableViewCell.self, for: indexPath)
            let review = reviewsList?[indexPath.row]
            let date = DateFormatter.isoDateFormatter.date(from: review?.createdAt ?? "")
            cell?.setTitle(review?.title ?? "")
            cell?.setSubtitle("\(date?.formatDateToDateTimeString ?? "") \(L10n.CourseDetails.CourseReview.by) \(review?.reviewer?.name ?? "")")
            cell?.setComment(review?.comment ?? "")
            cell?.setRating(review?.rating ?? 0.0)
            DispatchQueue.global().async {
                let image = self.getImage(from: review?.reviewer?.avatar?.fileUrl ?? "")
                cell?.setAvatarImage(image)
            }
            return cell ?? UITableViewCell()

        case .materials:
            let cell = tableView.dequeueCell(ofType: MaterialTableViewCell.self, for: indexPath)

            switch MaterialsSections(rawValue: indexPath.section) {
            case .assignments:
                let assignment = materials?.assignments?[indexPath.row]
                let date = assignment?.publishedAt ?? Date()
                cell?.configure(title: assignment?.title, date: date.formattedDateString, image: Images.quiz.image)

            case .quizzes:
                let quiz = materials?.quizzes?[indexPath.row]
                let date = quiz?.publishedAt ?? Date()
                cell?.configure(title: quiz?.title, date: date.formattedDateString, image: Images.quiz.image)

            case .videos:
                let video = materials?.videos?[indexPath.row]
                let date = video?.publishedAt ?? Date()
                cell?.configure(
                    title: video?.title,
                    date: date.formattedDateString,
                    image: !(video?.link?.isEmpty ?? true)
                        ? Images.link.image
                        : Images.videoExtension.image
                )

            case .documents:
                let document = materials?.documents?[indexPath.row]
                let date = document?.publishedAt ?? Date()
                cell?.configure(title: document?.title ?? document?.fileName, date: date.formattedDateString, image: getCorrespondingImage(for: document))

            default:
                return cell ?? UITableViewCell()
            }
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()

        default:
            return UITableViewCell()
        }
    }
}

// MARK: - Table View Delegate

extension CourseDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch activeScreen! {
        case .details:
            return detailsRowHeight
        case .materials, .reviews:
            return reviewsRowHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch activeScreen! {
        case .details:
            return detailsRowHeight
        case .materials:
            return reviewsRowHeight
        case .reviews:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard activeScreen == .details, !lessonsList.isEmpty else { return nil }

        let view = self.tableView.dequeueHeaderFooterView(ofType: CourseDetailsHeaderView.self)
        view?.tag = section
        view?.collapseExpandDelegate = self
        let lesson = lessonsList[section]
        view?.setLessonTitleLabel(lesson.name)
        view?.setNumberLabel(lessonNumbersList?[section] ?? 0)
        view?.assignSectionTagToButton(section)
        view?.configureVisibilityOfExpandButton(
            state: course?.reservationState,
            doesContainAttachments:
                doesLessonContainAttachments[section] ?? false
        )
        if expandedSections.contains(section) {
            view?.setImageOfButton(Images.collapse.image)
        } else {
            view?.setImageOfButton(Images.expand.image)
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return activeScreen == .details ? 60 : 0.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return activeScreen == .details ? 60 : 0.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        configureAttachments(in: indexPath.section)
        if activeScreen == .materials {
            switch MaterialsSections(rawValue: indexPath.section) {
            case .videos:
                if !(materials?.videos?[indexPath.row].link?.isEmpty ?? true) {
                    if let url = URL(string: materials?.videos?[indexPath.row].link ?? "") {
                        if materials?.videos?[indexPath.row].link?.contains("youtu.be") ?? false || materials?.videos?[indexPath.row].link?.contains("youtube") ?? false {
                            let headerview = tableView.tableHeaderView as? CourseDetailsInfoHeaderView
                            headerview?.playYoutubeVideo(videoLink: materials?.videos?[indexPath.row].link ?? "")
                            tableView.setContentOffset(.zero, animated: false)
                        } else {
                            UIApplication.shared.open(url)
                        }
                    }
                } else if !(materials?.videos?[indexPath.row].vdocipherId?.isEmpty ?? true) {
                    fetchAndPlayVideo(videoId: String(materials?.videos?[indexPath.row].id ?? .zero), viewsCount: materials?.videos?[indexPath.row].viewsRemaining ?? .zero)
                }
            case .documents:
                activeSubscreen = .file
                if let linkURL = materials?.documents?[indexPath.row].link {
                    let safariViewCtrl = SFSafariViewController(url: URL(string: linkURL)!)
                    present(safariViewCtrl, animated: true)
                } else {
                    let documentURL = Environment.baseURL.appendingPathComponent(materials?.documents?[indexPath.row].fileUrl ?? "")
                    storeAndShare(withURLString: documentURL.absoluteString)
                }
            case .quizzes:
                let cell = tableView.cellForRow(at: indexPath) as? MaterialTableViewCell
                cell?.startLoadingIndicator()
                activeSubscreen = .quiz
                quizzesViewModel?.assessments = materials?.quizzes ?? []
                let quiz = materials?.quizzes?[indexPath.row]
                selectedAssessment = quiz
                switch quiz?.status {
                case "open":
                    self.startAssessment(for: .quiz, at: indexPath)
                case "closed":
                    self.showResultForRow(for: quiz?.type ?? "Quiz", at: indexPath)
                default:
                    return
                }
            case .assignments:
                activeSubscreen = .exercise
                assignemntsViewModel?.assessments = materials?.assignments ?? []
                let assignment = materials?.assignments?[indexPath.row]
                selectedAssessment = assignment
                switch assignment?.status {
                case "open":
                    self.startAssessment(for: .assignment, at: indexPath)
                case "closed":
                    self.showResultForRow(for: assignment?.type ?? "Assignment", at: indexPath)
                default:
                    return
                }

            default:
                return
            }
        } else if activeScreen == .details {
            let attachment = allAttachmentsOfLesson[indexPath.row]
            if let assignment = attachment as? Assessment, assignment.type != "Quiz" {
                activeSubscreen = .exercise
                selectedAssessmentSection = indexPath.section
                assignemntsViewModel?.assessments = attachmentsOfLessons[indexPath.section]?.assignments ?? []
                switch assignment.status {
                case "open":
                    self.startAssessment(for: .assignment, at: indexPath)
                case "closed":
                    self.showResultForRow(for: assignment.type ?? "Assignment", at: indexPath)
                default:
                    return
                }
            } else if let quiz = attachment as? Assessment, quiz.type == "Quiz"{
                activeSubscreen = .quiz
                selectedAssessmentSection = indexPath.section
                quizzesViewModel?.assessments = attachmentsOfLessons[indexPath.section]?.quizzes ?? []
                selectedAssessment = quiz
                switch quiz.status {
                case "open":
                    self.startAssessment(for: .quiz, at: indexPath)
                case "closed":
                    self.showResultForRow(for: quiz.type ?? "Quiz", at: indexPath)
                default:
                    return
                }
            } else if let video = attachment as? Video {
                if let url = URL(string: video.link ?? "") {
                    if video.link?.contains("youtu.be") ?? false || video.link?.contains("youtube") ?? false {
                        let headerview = tableView.tableHeaderView as? CourseDetailsInfoHeaderView
                        headerview?.playYoutubeVideo(videoLink: video.link ?? "")
                        tableView.setContentOffset(.zero, animated: false)
                    } else {
                        UIApplication.shared.open(url)
                    }
                } else if !(video.vdocipherId?.isEmpty ?? true) {
                    fetchAndPlayVideo(videoId: String(video.id), viewsCount: video.viewsRemaining ?? .zero)
                }
            } else if let document = attachment as? MaterialsDocument {
                activeSubscreen = .file
                if let linkURL = document.link {
                    let safariViewCtrl = SFSafariViewController(url: URL(string: linkURL)!)
                    present(safariViewCtrl, animated: true)
                } else {
                    let documentURL = Environment.baseURL.appendingPathComponent(document.fileUrl ?? "")
                    storeAndShare(withURLString: documentURL.absoluteString)
                }
            }
        }
    }
}

// MARK: - Collapse Expand Delegate

extension CourseDetailsViewController: CollapseExpandDelegate {
    func didTapOnCollapseExpand(in section: Int) {
        handleAttachmentsExpantion(section: section)
    }
}

// MARK: - Receipt Done Button Delegate

extension CourseDetailsViewController: ReceiptDoneButtonDelegate {
    func didTapDone() {
        blurredView?.removeFromSuperview()
    }
}

// MARK: - Cancel Booking View Delegate

extension CourseDetailsViewController: CancelBookingViewDelegate {
    func didTapCancelBooking() {
        blurredView?.removeFromSuperview()
        viewModel?.cancelBookingCourse(courseID: course?.id ?? 0) { isCancellingSuccessful in
            if isCancellingSuccessful {
                self.state = .normal
                self.actionButton.setTitle(L10n.CourseDetails.Main.bookNow)
            }
        }
    }

    func didTapReturn() {
        blurredView?.removeFromSuperview()
    }
}

// MARK: - Review Course View Delegate

extension CourseDetailsViewController: ReviewCourseViewDelegate {
    func didTapSendButton(courseReview: CourseReview) {
        viewModel?.sendReview(courseID: course?.id ?? 0, courseReview: courseReview) { isSentSuccessfully in
            if isSentSuccessfully {
                self.blurredView?.removeFromSuperview()
            }
        }
    }

    func didTapSkipButton() {
        blurredView?.removeFromSuperview()
    }
}

// MARK: - Document Interaction Controller Delegate

extension CourseDetailsViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// MARK: - Assessment Details Delegate

extension CourseDetailsViewController: AssessmentDetailsDelegate {
    func didFinishAssessment(with id: Int?) {
        tableView.reloadData()
    }
}

// MARK: - vdoCipher Functions

extension CourseDetailsViewController {
    func fetchAndPlayVideo(videoId: String, viewsCount: Int) {
        vdoPlayerView.player = player
        if viewsCount > .zero {
        viewModel?.fetchVideoDetails(videoId: videoId) { [weak self] encryptedVideoResponse in
                guard let self = self else { return }
            AlertHandler(presentingViewCtrl: self).showConfirmAlert(title: L10n.Global.Titles.warning, message: L10n.CourseDetails.CourseReview.playVideo(viewsCount), confirmButtonTitle: L10n.Global.Actions.confirm, handler: { _ in
                    do {
                        self.showLoadingIndicator()
                        try self.vdoPlayerView.loadVideo(
                            otp: encryptedVideoResponse?.otp ?? "",
                            playbackInfo: encryptedVideoResponse?.playback ?? "",
                            onPlayerReady: {
                                self.hideLoadingIndicator()
                                let playerController = self.avPlayerController
                                playerController.player = self.vdoPlayerView.player
                                self.present(playerController, animated: true, completion: {
                                    let titleLayer = CATextLayer()
                                    titleLayer.string = "Wojod Academy \(User.shared.mobileNumber ?? "")"
                                    titleLayer.font = UIFont(font: FontFamily.Roboto.regular, size: 16)
                                    titleLayer.alignmentMode = .left
                                    self.setupPlayerLayerFrame(titleLayer)
                                    playerController.view.layer.addSublayer(titleLayer)
                                    self.updateId = encryptedVideoResponse?.updateId ?? .zero
                                    self.videoId = videoId
                                    self.checkForTime()
                                    self.vdoPlayerView.player?.play()
                                    self.checkForBufferedTime()
                                })
                            }
                        )
                    }  catch {
                        self.hideLoadingIndicator()
                        AlertHandler(presentingViewCtrl: self).showConfirmAlert(
                            title: L10n.Global.Titles.error,
                            message: L10n.Global.Alerts.somethingWentWrong
                        )
                    }
                })
            }
        } else {
            AlertHandler(presentingViewCtrl: self).showInformationAlert(
                title: L10n.Global.Titles.error,
                message: L10n.CourseDetails.Main.notEnoughViews
            )
        }
    }
}

extension CourseDetailsViewController {
    private func checkForBufferedTime() {
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkForTime), userInfo: nil, repeats: true)
    }

    @objc
    private func checkForTime() {
        let updateObject = UpdateObject(updateId: self.updateId, totalBuffered: Int(self.vdoPlayerView.player?.currentItem?.totalBuffer() ?? .zero))
        updateVideo(videoId: self.videoId, updateObject: updateObject)
    }
}

extension CourseDetailsViewController {
    func updateVideo(videoId: String, updateObject: UpdateObject) {
        viewModel?.updateVideo(videoId: videoId, updateObject: updateObject)
    }
}
// MARK: - Course Details Info Delegate

extension CourseDetailsViewController: CourseDetailsInfoHeaderDelegate {
    func showDetails() {
        activeScreen = .details
        self.tableView.reloadData()

    }

    func showMaterials() {
        activeScreen = .materials
        guard let courseID = course?.id else { return }
        viewModel?.loadMaterials(courseID: courseID) { materials in
            self.materials = materials
            self.tableView.reloadData()
        }
    }

    func showReviews() {
        activeScreen = .reviews
        viewModel?.loadReviews(courseID: course?.id ?? 0) { result in
            self.reviewsList = result.reviews
            self.tableView.reloadData()
        }
    }

    func goToChat() {
        let viewCtrl = StoryboardScene.Chat.chatContainerViewController.instantiate()
        viewCtrl.modalPresentationStyle = .fullScreen
        viewCtrl.chatType = .teacher(courseID: course?.id ?? 0, teacherID: teacherID ?? 0)
        present(viewCtrl, animated: true)
    }

    func dismissView() {
        dismiss(animated: true)
    }

    func playCourseVideo(playerController: AVPlayerViewController) {
        addChild(playerController)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
            self.avPlayerController.view.layer.sublayers?.forEach { layer in
                self.setupPlayerLayerFrame(layer)
            }
        }
    }

    private func setupPlayerLayerFrame(_ layer: CALayer) {
        guard let layer = layer as? CATextLayer else { return }

        let videoBounds = avPlayerController.videoBounds
        let width: CGFloat = 175.0
        let xPoint = videoBounds.maxX - width
        layer.frame = CGRect(x: xPoint, y: videoBounds.minY + 30, width: width, height: 50)
    }
}

// MARK: - DZN Empty State Data Source

extension CourseDetailsViewController: DZNEmptyDataSetSource {
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        switch activeScreen {
        case .details:
            return NSAttributedString(string: L10n.CourseDetails.CourseReview.emptyDetails)

        case .materials:
            return NSAttributedString(string: L10n.CourseDetails.CourseReview.emptyMaterials)

        case .reviews:
            return NSAttributedString(string: L10n.CourseDetails.CourseReview.emptyReviews)
        default:
            return nil
        }
    }
}

// MARK: - DZN Empty State Delegate

extension CourseDetailsViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 250
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        switch activeScreen {
        case .details:
            return lessonsList.isEmpty
        case .materials:
            return materials?.assignments?.isEmpty ?? true
                && materials?.documents?.isEmpty ?? true
                && materials?.quizzes?.isEmpty ?? true
                && materials?.videos?.isEmpty ?? true
        case .reviews:
            return reviewsList?.isEmpty ?? true
        default:
            return false
        }
    }
}

extension CourseDetailsViewController {
    func showQuizAlert() {
        quizzesViewModel?.showQuizAlet = { [weak self] error in
            self?.dismissAlertView()
            self?.showAlert(imageName: Images.danger.name, title: L10n.Global.Titles.error, message: error)
        }
    }
}
