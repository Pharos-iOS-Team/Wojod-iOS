// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

internal enum CourseState {
    case normal
    case pending
    case booked
}

internal enum ActiveScreen {
    case details
    case reviews
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
            actionButton.layer.cornerRadius = 10
            actionButton.setTitle(L10n.CourseDetails.Main.bookNow)
        }
    }
    @IBOutlet private var courseTitle: UILabel!
    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var numberOfReviewsLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var courseImageView: UIImageView!

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

    // MARK: - Public Properties

    internal var course: Course?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        state = getReservationState()
        activeScreen = .details
        viewModel = CourseDetailsViewModel()
        configureActionButtonAccordingToState()
        loadCourseLessons()
        configureTableView()
    }

    // MARK: - IBActions

    @IBAction private func didTapDetails(_ sender: UIButton) {
        activeScreen = .details
        tableView.reloadData()
        select(button: detailsButton)
        unselect(button: materialsButton)
        unselect(button: reviewsButton)
    }

    @IBAction private func didTapMaterials(_ sender: UIButton) {
        select(button: materialsButton)
        unselect(button: detailsButton)
        unselect(button: reviewsButton)
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
        courseImageView.image = getImage(from: course?.media?.fileUrl ?? "")
        courseTitle.text = course?.name
        descriptionLabel.text = course?.summary
        priceLabel.text = "EGP \(course?.price ?? "")"
        numberOfReviewsLabel.text = "\(course?.reviewsCount ?? 0)"
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
        tableView.register(UINib(nibName: "AttachmentTableViewCell", bundle: nil), forCellReuseIdentifier: "AttachmentTableViewCell")
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewTableViewCell")
        let headerNib = UINib(nibName: "CourseDetailsHeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "CourseDetailsHeaderView")
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
        if let imageURLString = imageURLString, let imageURL = URL(string: imageURLString),
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

    private func configureAttachments(_ attachments: LessonAttachmentsModel?, _ cell: AttachmentTableViewCell?) {
        if let assignments = attachments?.assignments {
            for assignment in assignments {
                cell?.setSubtitleLabel(assignment.title ?? "Assignment")
                cell?.setAttachmentImageView(Images.quiz.image)
            }
        }
    }

    private func configureQuizzes(_ attachments: LessonAttachmentsModel?, _ cell: AttachmentTableViewCell?) {
        if let quizzes = attachments?.quizzes {
            for quiz in quizzes {
                cell?.setSubtitleLabel(quiz.title ?? "Quiz")
                cell?.setAttachmentImageView(Images.quiz.image)
            }
        }
    }

    private func configureVideos(_ attachments: LessonAttachmentsModel?, _ cell: AttachmentTableViewCell?) {
        if let videos = attachments?.videos {
            for video in videos {
                cell?.setSubtitleLabel(video.title ?? "Video")
            }
        }
    }

    private func configureDocuments(_ attachments: LessonAttachmentsModel?, _ cell: AttachmentTableViewCell?) {
        if let documents = attachments?.documents {
            for document in documents {
                cell?.setOptionalTitleLabel(document.title ?? "File")
                cell?.setSubtitleLabel(document.fileName ?? "")
                cell?.setAttachmentImageView(Images.pdf.image)
            }
        }
    }

    private func configureAttachmentCell(_ cell: AttachmentTableViewCell?, _ section: Int) {
        let attachments = attachmentsOfLessons[section]
        configureAttachments(attachments, cell)
        configureQuizzes(attachments, cell)
        configureVideos(attachments, cell)
        configureDocuments(attachments, cell)
    }
}

// MARK: - Table View Data Source

extension CourseDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return activeScreen == .details ? lessonsList?.count ?? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activeScreen {
        case .reviews:
            return reviewsList?.count ?? 0
        case .details:
            return numberOfRowsInLessonSection(section)
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch activeScreen {
        case .details:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentTableViewCell", for: indexPath) as? AttachmentTableViewCell
            configureAttachmentCell(cell, indexPath.section)
            return cell ?? UITableViewCell()

        case .reviews:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as? ReviewTableViewCell
            let review = reviewsList?[indexPath.row]
            cell?.setTitle(review?.title ?? "")
            cell?.setSubtitle("\(review?.createdAt ?? "") by \(review?.reviewer?.name ?? "")")
            cell?.setComment(review?.comment ?? "")
            cell?.setRating(viewModel?.ratingFromUserPercentage(review?.rating ?? 0) ?? 0)
            cell?.setAvatarImage(imageFromURL(review?.reviewer?.avatar?.fileUrl ?? ""))
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
            let view = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CourseDetailsHeaderView")  as? CourseDetailsHeaderView
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
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        view.backgroundColor = Colors.lightGreyColor.color
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }
}

// MARK: - Collapse Expand Delegate

extension CourseDetailsViewController: CollapseExpandDelegate {
    func didTapOnCollapseExpand(in section: Int) {
        if expandedSections.contains(section) {
            if let index = expandedSections.firstIndex(of: section) {
                expandedSections.remove(at: index)
            }
            self.attachmentsOfLessons[section] = LessonAttachmentsModel()
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
        viewModel?.cancelBookingCourse(courseID: 32) { isCancellingSuccessful in
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
        viewModel?.sendReview(courseID: 35, courseReview: courseReview) { isSentSuccessfully in
            if isSentSuccessfully {
                self.blurredView?.removeFromSuperview()
            }
        }
    }

    func didTapSkipButton() {
        blurredView?.removeFromSuperview()
    }
}
