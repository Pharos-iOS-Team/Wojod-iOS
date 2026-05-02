// Copyright © 2021 Pharos Solutions. All rights reserved.
// swiftlint:disable all

import AVKit
import AVFoundation
import DZNEmptyDataSet
import HandySwift
import JGProgressHUD
import UIKit
import SafariServices
import VdoFramework
import Photos
import ComposableArchitecture
import SwiftUI

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

enum MaterialsSections: Int, CaseIterable {
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
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var actionButton: UIButton! {
        didSet {
            actionButton.layer.cornerRadius = UIConstants.cornerRadius
            actionButton.setTitle(L10n.CourseDetails.Main.contactUs)
        }
    }
    @IBOutlet private var bookByQRButton: UIButton! {
        didSet {
            bookByQRButton.layer.cornerRadius = UIConstants.cornerRadius
            bookByQRButton.setTitle(L10n.CourseDetails.Main.bookByQR)
        }
    }
    
    var isContactInfoAvailable: Bool { (course.contactUsInfo?.isValid ?? false) }

    // MARK: - Private Properties

    private var player: AVPlayer?
    private var state: CourseState?
    private var activeScreen: ActiveScreen = .details
    private var viewModel: CourseDetailsViewModel?
    private var quizzesViewModel: AssessmentsOverViewViewModel?
    private var assignemntsViewModel: AssessmentsOverViewViewModel?
    private var lessonsList: [Lesson] = []
    private var lessonNumbersList: [Int]?
    private var reviewsList: [Review] = []
    private var attachmentsOfLessons: [Int: LessonAttachmentsModel] = [:]
    private var expandedSections: [Int] = []
    private var blurredView: UIVisualEffectView?
    private let detailsRowHeight: CGFloat = 50
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
    private var alertHandler: AlertHandler?

    // MARK: - Public Properties

    var course: Course!
    var hideViews: Bool = false
    var teacherName: String?
    var teacherID: Int?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        VdoCipher.setPlaybackDelegate(delegate: self)
        state = getReservationState()
        viewModel = CourseDetailsViewModel()
        quizzesViewModel = AssessmentsOverViewViewModel(module: .quizzes)
        assignemntsViewModel = AssessmentsOverViewViewModel(module: .assignments)
        alertHandler = AlertHandler(presentingViewCtrl: self)
        configureActionButtonAccordingToState()
        loadCourseDetails()
        configureTableView()
        documentInteractionController.delegate = self
        bindStartAssessmentHandler()
        bindAssessmentResultsHandler()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        configureRefreshControl()
        observeInternetConnection()
        showQuizAlert()
        setHeader()
        shouldShowQRCodeScanner()
        applyScreenshotPreventingView()
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayerMuteState), name: UIScreen.capturedDidChangeNotification, object: nil)
    }

    private func setHeader() {
        let detailsView = CourseDetailsInfoHeaderView()
        detailsView.configure(
            model: CourseDetailsInfoModel(
                courseTitle: course?.name,
                teacherName: teacherName,
                batchName: course?.batchName,
                image: course?.media?.fileUrl,
                video: course?.video,
                description: course?.summary,
                price: coursePrice(),
                numberOfReviews: String(course?.reviewsCount ?? .zero),
                rating: course?.rating,
                shouldHideMaterials: state != .booked,
                buttonSelected: activeScreen,
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
        
        guard let courseID = course?.id else { return }
        if activeScreen == .materials {
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

    // MARK: - IBActions

    @IBAction private func didTapOnActionButton(_ sender: UIButton) {
        if viewModel?.isGuestModeEnabled() ?? false {
            showLoadingIndicator()
            viewModel?.logout()
        } else {
            switch state {
            case .normal:
                blurView()
                displayContactUsPopup()
                
            case .booked:
                blurView()
                displayReviewCoursePopup()
                
            default:
                return
            }
        }
    }

    @IBAction private func didTapOnQRCodeBooking(_ sender: UIButton) {
        if viewModel?.isGuestModeEnabled() ?? false {
            showLoadingIndicator()
            viewModel?.logout()
        } else {
            QRCodeActionSheet()
        }
    }

    // MARK: - Private Functions

    private func QRCodeActionSheet() {
        let alert = UIAlertController(title: L10n.CourseDetails.Main.bookByQR, message: "Please Select an Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: L10n.CourseDetails.Main.qrCodeScanner, style: .default , handler:{ _ in
            self.openQRCodeScannerScreen()
        }))
        alert.addAction(UIAlertAction(title: L10n.CourseDetails.Main.codeManually, style: .default , handler:{ _ in
            self.openQRCodeManuallyScreen()
        }))
        alert.addAction(UIAlertAction(title: L10n.Shared.Action.dismiss, style: .cancel))
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true)
    }

    private func openQRCodeScannerScreen() {
        let viewCtrl = StoryboardScene.CourseDetails.qrCodeScannerViewController.instantiate()
        viewCtrl.scanningCompletionHandler = { scannedCode in
            self.bookCourse(qrCode: scannedCode)
        }
        present(viewCtrl, animated: true)
    }

    private func openQRCodeManuallyScreen() {
        self.blurView()
        self.displayQRCodeManualScreen()
    }

    private func displayQRCodeManualScreen() {
        let qrVC = EnterQRCodeManuallyViewController(nibName: "EnterQRCodeManuallyViewController", bundle: nil)

        qrVC.scanningCompletionHandler = { [weak self] code in
            self?.blurredView?.removeFromSuperview()
            self?.bookCourse(qrCode: code)
        }
        qrVC.scanningDismissed = {
            self.blurredView?.removeFromSuperview()
        }

        qrVC.modalPresentationStyle = .overFullScreen
        qrVC.modalTransitionStyle = .crossDissolve

        self.present(qrVC, animated: true)
    }

    private func shouldShowQRCodeScanner() {
        let isQRCodeEnabled = (course.qrCodeEnabled ?? false)
        let shouldShowButton = isQRCodeEnabled && state == .normal
        bookByQRButton.isHidden = !shouldShowButton
    }

    private func bookCourse(qrCode: String? = nil) {
        viewModel?.bookCourses(qrCode: qrCode, courseID: course.id) { bookingResponse, error in
            if error == nil {
                if qrCode != nil {
                    self.handleBookingSuccessWithQR(bookingResponse: bookingResponse)
                } else {
                    self.handleBookingSuccess(bookingResponse: bookingResponse)
                }
            } else if let error = error as? WJError {
                self.showAlert(imageName: Images.danger.name, title: "Error", message: error.message)
            }
        }
    }

    private func handleBookingSuccessWithQR(bookingResponse: BookingCourseResponseModel?) {
        loadCourseDetails()
        if !self.isTestingAccount() {
            self.blurView()
            self.displayReceipt(bookingResponse!, coursePrice: self.course?.price ?? "")
        }
    }

    private func handleBookingSuccess(bookingResponse: BookingCourseResponseModel?) {
        self.state = .pending
        self.actionButton.setTitle(L10n.CourseDetails.Main.cancelBooking)
        if !self.isTestingAccount() {
            self.blurView()
            self.displayReceipt(bookingResponse!, coursePrice: self.course?.price ?? "")
        }
    }

    private func coursePrice() -> String {
        guard !isTestingAccount() else { return "" }
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
        guard !lessonsList[section].locked else {
            showAlert(imageName: Images.danger.name, title: L10n.Global.Titles.warning, message: lessonsList[section].lockMessage)
            return 
        }
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
                    if self.attachmentsOfLessons[section]?.assignments?.isEmpty ?? true &&
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
                if
                    self.attachmentsOfLessons[section]?.assignments?.isEmpty ?? true &&
                        self.attachmentsOfLessons[section]?.documents?.isEmpty ?? true &&
                        self.attachmentsOfLessons[section]?.quizzes?.isEmpty ?? true &&
                        self.attachmentsOfLessons[section]?.videos?.isEmpty ?? true
                {
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
        actionButton.isHidden = !isContactInfoAvailable
        switch state {
        case .normal:
            actionButton.setTitle(L10n.CourseDetails.Main.contactUs)
            
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
        let receiptVC = ReceiptViewController(nibName: "ReceiptViewController", bundle: nil)
        receiptVC.receiptData = receiptData
        receiptVC.coursePrice = coursePrice
        receiptVC.delegate = self
        
        receiptVC.modalPresentationStyle = .overFullScreen
        receiptVC.modalTransitionStyle = .crossDissolve
        
        self.present(receiptVC, animated: true)
    }

    private func displayContactUsPopup() {
        guard let contactUsInfo = course.contactUsInfo, isContactInfoAvailable else { return }
        
        let popupVC = ContactUsViewController(nibName: "ContactUsViewController", bundle: nil)
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.contactInfo = contactUsInfo
        popupVC.viewDismissed = {
            self.blurredView?.removeFromSuperview()
        }
        
        self.present(popupVC, animated: true)
    }

    private func displayReviewCoursePopup() {
        let reviewVC = ReviewCourseViewController(nibName: "ReviewCourseViewController", bundle: nil)
        reviewVC.delegate = self
        
        reviewVC.modalPresentationStyle = .overFullScreen
        reviewVC.modalTransitionStyle = .crossDissolve
        
        self.present(reviewVC, animated: true)
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
        viewModel?.loadLessons(courseID: course.id) { lessonsModel in
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
            cell?.setSubtitleLabel(assignment.title)
            cell?.setAttachmentImageView(Images.quiz.image)
        } else if let quiz = attachment as? Assessment {
            cell?.setSubtitleLabel(quiz.title)
            cell?.setAttachmentImageView(Images.quiz.image)
        } else if let video = attachment as? Video {
            cell?.setSubtitleLabel(video.title)
            cell?.setDuration(video.duration)
            cell?.setAvaliablity(video.daysRemaining)
            if (video.link?.isEmpty ?? true) || video.link.isYouTubeLink {
                cell?.setAttachmentImageView(Images.videoExtension.image)
            } else {
                cell?.setAttachmentImageView(Images.link.image)
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
            if document?.link.isYouTubeLink ?? false {
                return Images.videoExtension.image
            } else if document?.link != nil {
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

    private func presentPDF(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        showLoadingIndicator()
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self, let data, error == nil else { return }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "document.pdf")
            do {
                try data.write(to: tmpURL)
            } catch {
                return
            }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                let pdfVC = PDFViewController(itemUrl: tmpURL, dismissAction: { [weak self] in
                    self?.dismiss(animated: true)
                })
                let navController = UINavigationController(rootViewController: pdfVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
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
        loadCourseDetails()
    }

    private func loadCourseDetails() {
        viewModel?.loadCourse(courseID: "\(course.id)") { course in
            self.course = course.course
            self.hideViews = course.hideViews ?? false
            self.state = self.getReservationState()
            self.configureActionButtonAccordingToState()
            self.tableView.reloadData()
            self.handleRefreshingAccordingToOpenedTab()
            self.shouldShowQRCodeScanner()
        }
    }

    private func handleRefreshingAccordingToOpenedTab() {
        guard let course = course else { return }
        switch activeScreen {
        case .details:
            loadCourseLessons()
            tableView.refreshControl?.endRefreshing()

        case .materials:
            showLoadingIndicator()
            viewModel?.loadMaterials(courseID: course.id) { materials in
                self.hideLoadingIndicator()
                self.materials = materials
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }

        case .reviews:
            showLoadingIndicator()
            viewModel?.loadReviews(courseID: course.id) { result in
                self.hideLoadingIndicator()
                self.reviewsList = result.reviews ?? []
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
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
        case .reviews:
            return reviewsList.isEmpty ? 0 : 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activeScreen {
        case .reviews:
            return reviewsList.count
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
            let review = reviewsList[indexPath.row]
            let date = DateFormatter.isoDateFormatter.date(from: review.createdAt ?? "")
            cell?.setTitle(review.title ?? "")
            cell?.setSubtitle("\(date?.formatDateToDateTimeString ?? "") \(L10n.CourseDetails.CourseReview.by) \(review.reviewer?.name ?? "")")
            cell?.setComment(review.comment ?? "")
            cell?.setRating(review.rating ?? 0.0)
            DispatchQueue.global().async {
                let image = self.getImage(from: review.reviewer?.avatar?.fileUrl ?? "")
                cell?.setAvatarImage(image)
            }
            return cell ?? UITableViewCell()

        case .materials:
            let cell = tableView.dequeueCell(ofType: MaterialTableViewCell.self, for: indexPath)

            switch MaterialsSections(rawValue: indexPath.section)! {
            case .assignments:
                let assignment = materials?.assignments?[indexPath.row]
                let date = assignment?.publishedAt ?? Date()
                cell?.model = MaterialTableCellData(
                    title: assignment?.title,
                    date: date.formattedDateString,
                    image: Images.quiz.image
                )
            case .quizzes:
                let quiz = materials?.quizzes?[indexPath.row]
                let date = quiz?.publishedAt ?? Date()
                cell?.model = MaterialTableCellData(
                    title: quiz?.title,
                    date: date.formattedDateString,
                    image: Images.quiz.image
                )

            case .videos:
                let video = materials?.videos?[indexPath.row]
                let date = video?.publishedAt ?? Date()
                cell?.model = MaterialTableCellData(
                    title: video?.title,
                    date: date.formattedDateString,
                    image: ((video?.link?.isEmpty ?? true) || video?.link.isYouTubeLink == true)
                        ? Images.videoExtension.image
                        : Images.link.image,
                    duration: video?.duration
                )

            case .documents:
                let document = materials?.documents?[indexPath.row]
                let date = document?.publishedAt ?? Date()
                cell?.model = MaterialTableCellData(
                    title: document?.title ?? document?.fileName,
                    date: date.formattedDateString,
                    image: getCorrespondingImage(for: document)
                )
            }
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        }
    }
}

// MARK: - Table View Delegate

extension CourseDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch activeScreen {
        case .details:
            return detailsRowHeight
        case .materials, .reviews:
            return reviewsRowHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch activeScreen {
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
        if lessonsList[section].locked {
            view?.setImageOfButton(Images.lock.image)
        } else {
            if expandedSections.contains(section) {
                view?.setImageOfButton(Images.collapse.image)
            } else {
                view?.setImageOfButton(Images.expand.image)
            }
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
                guard let video =  materials?.videos?[indexPath.row], !video.locked else {
                    showAlert(imageName: Images.danger.name, title: L10n.Global.Titles.warning, message: materials?.videos?[indexPath.row].lockMessage ?? "")
                    return 
                }
                if video.isBunnyVideo {
                    presentBunnyVideo(video)
                } else if !(materials?.videos?[indexPath.row].link?.isEmpty ?? true) {
                    if let url = URL(string: materials?.videos?[indexPath.row].link ?? "") {
                        if materials?.videos?[indexPath.row].link.isYouTubeLink ?? false {
                            presentYouTubePlayer(url: url)
                        } else {
                            UIApplication.shared.open(url)
                        }
                    }
                } else if !(materials?.videos?[indexPath.row].vdocipherId?.isEmpty ?? true) {
                    if let video = materials?.videos?[indexPath.row] {
                        fetchAndPlayVideo(viewsCount: video.viewsRemaining ?? .zero, video: video)
                    }
                }
            case .documents:
                activeSubscreen = .file
                let doc = materials?.documents?[indexPath.row]
                if let linkURL = doc?.link {
                    let safariViewCtrl = SFSafariViewController(url: URL(string: linkURL)!)
                    present(safariViewCtrl, animated: true)
                } else {
                    let documentURL = AppEnvironment.baseURL.appendingPathComponent(doc?.fileUrl ?? "")
                    if doc?.contentType == "application/pdf" && AppEnvironment.appName == .squareCenter {
                        presentPDF(from: documentURL.absoluteString)
                    } else {
                        storeAndShare(withURLString: documentURL.absoluteString)
                    }
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
                guard !video.locked else {
                    showAlert(imageName: Images.danger.name, title: L10n.Global.Titles.warning, message: video.lockMessage ?? "")
                    return
                }
                if video.isBunnyVideo {
                    presentBunnyVideo(video)
                } else if let url = URL(string: video.link ?? "") {
                    if video.link.isYouTubeLink {
                        presentYouTubePlayer(url: url)
                    } else {
                        UIApplication.shared.open(url)
                    }
                } else if !(video.vdocipherId?.isEmpty ?? true) {
                    fetchAndPlayVideo(viewsCount: video.viewsRemaining ?? .zero, video: video)
                }
            } else if let document = attachment as? MaterialsDocument {
                activeSubscreen = .file
                if let linkURL = document.link {
                    let safariViewCtrl = SFSafariViewController(url: URL(string: linkURL)!)
                    present(safariViewCtrl, animated: true)
                } else {
                    let documentURL = AppEnvironment.baseURL.appendingPathComponent(document.fileUrl ?? "")
                    if document.contentType == "application/pdf" && AppEnvironment.appName == .squareCenter {
                        presentPDF(from: documentURL.absoluteString)
                    } else {
                        storeAndShare(withURLString: documentURL.absoluteString)
                    }
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

// MARK: - YouTube Player

extension CourseDetailsViewController {
    private func presentYouTubePlayer(url: URL) {
        var initialState = YouTubePlayer.State(videoURL: url)
        initialState.isMuted = UIScreen.main.isCaptured
        let store = StoreOf<YouTubePlayer>(initialState: initialState, reducer: { YouTubePlayer() })
        let hostingController = UIHostingController(rootView: YouTubePlayerView(store: store))
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
}

// MARK: - Video Playback Functions
extension CourseDetailsViewController {
    private func playVideoWithChecks<T>(viewsCount: Int, video: Video, presentPlayer: @escaping (T) -> Void) {
        guard viewsCount > .zero else {
            let errorMessage = hideViews ? L10n.CourseDetails.Main.videoPlaybackIssue : L10n.CourseDetails.Main.notEnoughViews
            alertHandler?.showInformationAlert(
                title: L10n.Global.Titles.error,
                message: errorMessage
            )
            return
        }
        
        viewModel?.fetchVideoDetails(videoId: "\(video.id)") { [weak self] response in
            guard let self else { return }
            
            if hideViews {
                self.showLoadingIndicator()
                presentPlayer(response as! T)
            } else {
                self.alertHandler?.showConfirmAlert(
                    title: L10n.Global.Titles.warning,
                    message: L10n.CourseDetails.CourseReview.playVideo(viewsCount),
                    confirmButtonTitle: L10n.Global.Actions.confirm
                ) { _ in
                    self.showLoadingIndicator()
                    presentPlayer(response as! T)
                }
            }
        }
    }
    
    func presentBunnyVideo(_ video: Video) {
        guard let guid = video.bunnyGuid,
              let libraryIdString = video.bunnyLibraryId,
              let libraryId = Int(libraryIdString),
              let apiKey = video.bunnyApiKey
        else { return }
        
        playVideoWithChecks(viewsCount: video.viewsRemaining ?? .zero, video: video) { [weak self] (_: EncryptedVideoResponse?) in
            guard let self else { return }
            let playerView = BunnyPlayerView(
                videoId: guid,
                libraryId: libraryId,
                apiKey: apiKey
            )
            let hostingController = UIHostingController(rootView: playerView)
            hostingController.modalPresentationStyle = .fullScreen
            self.hideLoadingIndicator()
            self.present(hostingController, animated: true)
        }
    }
    
    func fetchAndPlayVideo(viewsCount: Int, video: Video) {
        playVideoWithChecks(viewsCount: viewsCount, video: video) { [weak self] (encryptedVideoResponse: EncryptedVideoResponse?) in
            guard let self else { return }
            self.presentVideo(video, encryptedVideoResponse: encryptedVideoResponse)
        }
    }
    
    private func presentVideo(_ video: Video, encryptedVideoResponse: EncryptedVideoResponse?) {
        VdoAsset.createAsset(videoId: "\(video.vdocipherId ?? "")") { asset, error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.hideLoadingIndicator()
                    self?.alertHandler?.showConfirmAlert(
                        title: L10n.Global.Titles.error,
                        message: error.description
                    )
                } else if let otp = encryptedVideoResponse?.otp, let playback = encryptedVideoResponse?.playback {
                    guard let self = self else { return }
                    let vdoPlayerController: VdoPlayerViewController = VdoCipher.getVdoPlayerViewController()
                    vdoPlayerController.transitioningDelegate = self
                    asset?.playOnline(otp: otp, playbackInfo: playback)
                    self.present(vdoPlayerController, animated: true)
                    self.handleVideo(video, encryptedVideoResponse: encryptedVideoResponse, for: vdoPlayerController)
                }
            }
        }
    }
}

extension CourseDetailsViewController {
    private func handleVideo(_ video: Video, encryptedVideoResponse: EncryptedVideoResponse?, for vdoPlayerController: VdoPlayerViewController) {
        self.hideLoadingIndicator()
        self.updateId = encryptedVideoResponse?.updateId ?? .zero
        self.videoId = "\(video.id)"
        self.checkForBufferedTime()
    }
    
    private func checkForBufferedTime() {
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkForTime), userInfo: nil, repeats: true)
    }

    @objc
    private func checkForTime() {
        let updateObject = UpdateObject(updateId: self.updateId, totalBuffered: Int(self.player?.currentItem?.totalBuffer() ?? .zero))
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
        viewModel?.loadMaterials(courseID: course.id) { materials in
            self.materials = materials
            self.tableView.reloadData()
        }
    }

    func showReviews() {
        activeScreen = .reviews
        viewModel?.loadReviews(courseID: course.id) { result in
            self.reviewsList = result.reviews ?? []
            self.tableView.reloadData()
        }
    }

    func goToChat() {
        let viewCtrl = StoryboardScene.Chat.chatContainerViewController.instantiate()
        viewCtrl.modalPresentationStyle = .fullScreen
        viewCtrl.chatType = .teacher(courseID: course.id, teacherID: teacherID ?? 0)
        present(viewCtrl, animated: true)
    }

    func dismissView() {
        removeScreenshotPreventingView()
        dismiss(animated: true)
    }

    func playCourseVideo(playerController: AVPlayerViewController) {
        addChild(playerController)
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
        }
    }
}

// MARK: - DZN Empty State Delegate

extension CourseDetailsViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        guard let tableHeaderView = tableView.tableHeaderView else { return 200 }
        return tableHeaderView.frame.size.height / 2
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
            return reviewsList.isEmpty
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

// MARK: - AssetPlaybackDelegate
extension CourseDetailsViewController:  AssetPlaybackDelegate , UIViewControllerTransitioningDelegate{
    @objc private func updatePlayerMuteState() {
        player?.isMuted = UIScreen.main.isCaptured
    }

    func streamPlaybackManager(playerReadyToPlay player: AVPlayer) {
        self.player = player
        player.play()
        player.isMuted = UIScreen.main.isCaptured
    }
    
    func streamPlaybackManager(playerCurrentItemDidChange player: AVPlayer) {
        self.player = player
    }
    
    func streamLoadError(error: VdoFramework.VdoError) {
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        timer.invalidate()
        player = nil
        return nil
    }
}
