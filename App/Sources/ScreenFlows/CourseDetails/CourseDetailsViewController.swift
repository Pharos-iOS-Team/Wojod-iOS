// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
import HandySwift
import JGProgressHUD
import UIKit

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

internal enum MaterialsSections: Int {
    case assignments
    case quizzes
    case videos
    case documents
}

internal enum AttachmentType {
    case assignments
    case quizzes
    case videos
    case documents
}

class CourseDetailsViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var detailsButton: UIButton! {
        didSet {
            detailsButton.setTitle(L10n.CourseDetails.Main.details)
            detailsButton.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var materialsButton: UIButton! {
        didSet {
            materialsButton.layer.cornerRadius = UIConstants.cornerRadius
            materialsButton.isHidden = !(self.state == .booked)
        }
    }
    @IBOutlet private var reviewsButton: UIButton! {
        didSet {
            reviewsButton.setTitle(L10n.CourseDetails.Main.reviews)
            reviewsButton.layer.cornerRadius = UIConstants.cornerRadius
        }
    }
    @IBOutlet private var actionButton: UIButton! {
        didSet {
            actionButton.layer.cornerRadius = UIConstants.cornerRadius
            actionButton.setTitle(L10n.CourseDetails.Main.bookNow)
        }
    }
    @IBOutlet private var courseTitle: UILabel!
    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var numberOfReviewsLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var courseImageView: UIImageView!
    @IBOutlet private var firstReviewStar: UIImageView!
    @IBOutlet private var secondReviewStar: UIImageView!
    @IBOutlet private var thirdReviewStar: UIImageView!
    @IBOutlet private var fourthReviewStar: UIImageView!
    @IBOutlet private var fifthReviewStar: UIImageView!

    // MARK: - Private Properties

    private var state: CourseState?
    private var activeScreen: ActiveScreen?
    private var viewModel: CourseDetailsViewModel?
    private var lessonsList: [Lesson]?
    private var lessonNumbersList: [Int]?
    private var reviewsList: [Review]?
    private var attachmentsOfLessons: [Int: LessonAttachmentsModel] = [:]
    private var expandedSections: [Int] = []
    private var blurredView: UIVisualEffectView?
    private let detailsRowHeight: CGFloat = 65
    private let reviewsRowHeight: CGFloat = 100
    private let detailsHeaderHeight: CGFloat = 60
    private let footerHeight: CGFloat = 1
    private var materials: Materials?
    private var documentInteractionController = UIDocumentInteractionController()
    private var loadingHud: JGProgressHUD?
    private var numberOfSectionsInMaterials: Int = 4
    private var allAttachmentsOfLesson: [Any] = []

    // MARK: - Public Properties

    var course: Course?
    var teacherName: String?
    var teacherID: Int?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        state = getReservationState()
        activeScreen = .details
        viewModel = CourseDetailsViewModel()
        configureActionButtonAccordingToState()
        configureVisibilityOfButtonsAccordingToState()
        loadCourseLessons()
        configureTableView()
        documentInteractionController.delegate = self
    }

    // MARK: - IBActions

    @IBAction private func didTapDetails(_ sender: UIButton) {
        activeScreen = .details
        tableView.reloadData()
        select(button: detailsButton)
        unselect(button: materialsButton)
        unselect(button: reviewsButton)
    }

    @IBAction private func didTapChat(_ sender: UIButton) {
        let viewCtrl = StoryboardScene.Chat.chatContainerViewController.instantiate()
        viewCtrl.modalPresentationStyle = .fullScreen
        viewCtrl.chatType = .teacher(courseID: course?.id ?? 0, teacherID: teacherID ?? 0)
        present(viewCtrl, animated: true)
    }

    @IBAction private func didTapMaterials(_ sender: UIButton) {
        activeScreen = .materials
        select(button: materialsButton)
        unselect(button: detailsButton)
        unselect(button: reviewsButton)

        guard let courseID = course?.id else { return }
        viewModel?.loadMaterials(courseID: courseID) { materials in
            self.materials = materials
            self.tableView.reloadData()
        }
    }

    @IBAction private func didTapReviews(_ sender: UIButton) {
        viewModel?.loadReviews(courseID: course?.id ?? 0) { result in
            self.reviewsList = result.reviews
            self.tableView.reloadData()
        }
        activeScreen = .reviews
        select(button: reviewsButton)
        unselect(button: detailsButton)
        unselect(button: materialsButton)
    }

    @IBAction private func didTapOnActionButton(_ sender: UIButton) {
        switch state {
        case .normal:
            viewModel?.bookCourses(courseID: course?.id ?? 0) { bookingResponse in
                self.state = .pending
                self.actionButton.setTitle(L10n.CourseDetails.Main.cancelBooking)
                self.blurView()
                self.displayReceipt(bookingResponse)
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

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - Private Functions

    private func configure() {
        teacherNameLabel.text = teacherName
        courseImageView.image = getImage(from: course?.media?.fileUrl ?? "")
        courseTitle.text = course?.name
        descriptionLabel.text = course?.summary
        priceLabel.text = "EGP \(course?.price ?? "")"
        numberOfReviewsLabel.text = "\(course?.reviewsCount ?? 0)"
        setRating(Int(course?.rating ?? 0.0))
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

    private func configureVisibilityOfButtonsAccordingToState() {
        materialsButton.isHidden = state != .booked
    }

    private func blurView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        self.view.addSubview(blurredView ?? blurEffectView)
    }

    private func displayReceipt(_ receiptData: BookingCourseResponseModel) {
        let view = UINib(nibName: "ReceiptView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ReceiptView
        view?.center = CGPoint(
            x: self.view.frame.size.width / 2,
            y: self.view.frame.size.height / 2
        )
        view?.configure(with: receiptData)
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
    }

    private func select(button: UIButton) {
        button.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        button.setTitleColor(Colors.sendButtonColor.color, for: .normal)
    }

    private func unselect(button: UIButton) {
        button.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
    }

    private func loadCourseLessons() {
        viewModel?.loadLessons(courseID: course?.id ?? 0) { lessonsModel in
            self.lessonsList = lessonsModel.lessons
            self.generateLessonsNumbersList()
            self.tableView.reloadData()
        }
    }

    private func generateLessonsNumbersList() {
        guard lessonsList?.count ?? 0 >= 1 else { return }
        let numberOfLessons = lessonsList?.count ?? 0
        lessonNumbersList = Array(1 ... numberOfLessons)
    }

    private func imageFromURL(_ imageURLString: String?) -> UIImage? {
        if let imageURLString = imageURLString, let imageURL = URL(string: "\(Environment.baseURL)\(imageURLString)"),
        let imageData = try? Data(contentsOf: imageURL) {
            return UIImage(data: imageData)
        }
        return nil
    }

    private func numberOfRowsInLessonSection(_ sectionNumber: Int) -> Int {
        let attachments = attachmentsOfLessons[sectionNumber]
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
        } else if let quiz = attachment as? Quiz {
            cell?.setSubtitleLabel(quiz.title ?? "")
            cell?.setAttachmentImageView(Images.quiz.image)
        } else if let video = attachment as? Video {
            cell?.setSubtitleLabel(video.title ?? "")
        } else if let document = attachment as? Document {
            cell?.setSubtitleLabel(document.fileName ?? "")
            cell?.setAttachmentImageView(Images.pdf.image)
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
        default:
            return Images.unknownExtension.image
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

    private func play(videoURL: URL) {
        showLoadingIndicator()
        let player = AVPlayer(url: videoURL)
        let playerViewCtrl = AVPlayerViewController()
        playerViewCtrl.player = player
        present(playerViewCtrl, animated: true) {
            self.hideLoadingIndicator()
            player.play()
        }
    }

    // swiftlint:disable function_body_length
    private func setRating(_ rating: Int) {
        switch rating {
        case 1:
            firstReviewStar.image = Images.filledStar.image
        case 2:
            firstReviewStar.image = Images.filledStar.image
            secondReviewStar.image = Images.filledStar.image
        case 3:
            firstReviewStar.image = Images.filledStar.image
            secondReviewStar.image = Images.filledStar.image
            thirdReviewStar.image = Images.filledStar.image
        case 4:
            firstReviewStar.image = Images.filledStar.image
            secondReviewStar.image = Images.filledStar.image
            thirdReviewStar.image = Images.filledStar.image
            fourthReviewStar.image = Images.filledStar.image
        case 5:
            firstReviewStar.image = Images.filledStar.image
            secondReviewStar.image = Images.filledStar.image
            thirdReviewStar.image = Images.filledStar.image
            fourthReviewStar.image = Images.filledStar.image
            fifthReviewStar.image = Images.filledStar.image
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
            return lessonsList?.count ?? 0
        case .materials:
            return numberOfSectionsInMaterials
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activeScreen {
        case .reviews:
            return reviewsList?.count ?? 0

        case .details:
            return numberOfRowsInLessonSection(section)

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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = dateFormatter.date(from: review?.createdAt ?? "")
            cell?.setTitle(review?.title ?? "")
            cell?.setSubtitle("\(date?.formatDateToDateTimeString ?? "") by \(review?.reviewer?.name ?? "")")
            cell?.setComment(review?.comment ?? "")
            cell?.setRating(review?.rating ?? 0)
            DispatchQueue.global().async {
                let image = self.getImage(from: review?.reviewer?.avatar?.fileUrl ?? "")
                cell?.setAvatarImage(image)
            }
            return cell ?? UITableViewCell()

        case .materials:
            let cell = tableView.dequeueCell(ofType: MaterialTableViewCell.self, for: indexPath)
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

            switch MaterialsSections(rawValue: indexPath.section) {
            case .assignments:
                let assignment = materials?.assignments?[indexPath.row]
                let date = inputFormatter.date(from: assignment?.publishedAt ?? "") ?? Date()
                cell?.configure(title: assignment?.title, date: date.formattedDateString, image: Images.quiz.image)

            case .quizzes:
                let quiz = materials?.quizzes?[indexPath.row]
                let date = inputFormatter.date(from: quiz?.publishedAt ?? "") ?? Date()
                cell?.configure(title: quiz?.title, date: date.formattedDateString, image: Images.quiz.image)

            case .videos:
                let video = materials?.videos?[indexPath.row]
                let date = inputFormatter.date(from: video?.publishedAt ?? "") ?? Date()
                cell?.configure(title: video?.title, date: date.formattedDateString, image: Images.videoExtension.image)

            case .documents:
                let document = materials?.documents?[indexPath.row]
                let date = inputFormatter.date(from: document?.publishedAt ?? "") ?? Date()
                cell?.configure(title: document?.fileName ?? document?.title, date: date.formattedDateString, image: getCorrespondingImage(for: document))

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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return activeScreen == .details ? detailsRowHeight : reviewsRowHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch activeScreen {
        case .details:
            let view = self.tableView.dequeueHeaderFooterView(ofType: CourseDetailsHeaderView.self)
            view?.collapseExpandDelegate = self
            let lesson = lessonsList?[section]
            view?.setLessonTitleLabel(lesson?.name ?? "Lesson")
            view?.setNumberLabel(lessonNumbersList?[section] ?? 0)
            view?.assignSectionTagToButton(section)
            if expandedSections.contains(section) {
                view?.setImageOfButton(Images.collapse.image)
            } else {
                view?.setImageOfButton(Images.expand.image)
            }
            return view

        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return activeScreen == .details ? detailsHeaderHeight : 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if activeScreen == .details {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
            view.backgroundColor = Colors.lightGreyColor.color
            return view
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return activeScreen == .details ? footerHeight : 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if activeScreen == .materials {
            switch MaterialsSections(rawValue: indexPath.section) {
            case .videos:
                let videoURL = Environment.baseURL.appendingPathComponent(materials?.videos?[indexPath.row].fileUrl ?? "")
                play(videoURL: videoURL)

            case .documents:
                let documentURL = Environment.baseURL.appendingPathComponent(materials?.documents?[indexPath.row].fileUrl ?? "")
                storeAndShare(withURLString: "\(documentURL)")

            default:
                return
            }
        }
    }
}

// MARK: - Collapse Expand Delegate

extension CourseDetailsViewController: CollapseExpandDelegate {
    func didTapOnCollapseExpand(in section: Int) {
        if expandedSections.contains(section) {
            if let index = expandedSections.firstIndex(of: section) {
                expandedSections.remove(at: index)
            }
            self.attachmentsOfLessons[section] = nil
            self.tableView.reloadData()
        } else {
            expandedSections.append(section)
            viewModel?.loadAttachmentsOfLesson(lessonID: lessonsList?[section].id ?? 0) { attachmentsModel in
                self.attachmentsOfLessons[section] = attachmentsModel
                self.tableView.reloadData()
            }
        }
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

extension CourseDetailsViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
