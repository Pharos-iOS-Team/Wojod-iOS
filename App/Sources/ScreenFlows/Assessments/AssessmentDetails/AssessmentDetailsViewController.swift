// Copyright © 2020 Pharos Solutions. All rights reserved.

import JGProgressHUD
import LanguageManager_iOS
import UIKit

protocol AssessmentQuestionsDelegate: AnyObject {
    func didAnswerQuestion(with questionID: Int?)
    func didAttachFile(with url: URL, for questionID: Int?)
    func didDeleteAttachedFile(for questionID: Int?)
    func didOpenAttachment(with url: URL?, needsDownload: Bool, questionID: Int?)
    func teacherAddOrEditComment(comment: String)
}

enum AssessmentDetailOverViewState {
    case expanded
    case collapsed
}

// swiftlint:disable all
class AssessmentDetailsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var timerDurationLabel: UILabel!
    @IBOutlet private var separator: UIView!
    @IBOutlet private var progressViewBorder: UIView!
    @IBOutlet private var timerLabel: UILabel!
    @IBOutlet private var timerStackView: UIStackView!
    @IBOutlet private var progressView: UIProgressView! {
        didSet {
            progressView.trackTintColor = .clear
            progressView.progressTintColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(0.3)
        }
    }
    @IBOutlet private var questionNumberCollectionView: UICollectionView! {
        didSet {
            questionNumberCollectionView.delegate = self
            questionNumberCollectionView.dataSource = self
        }
    }
    @IBOutlet private var questionsCollectionViewFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            questionsCollectionViewFlowLayout.minimumLineSpacing = collectionViewFlowLayoutSpacing
            questionsCollectionViewFlowLayout.minimumInteritemSpacing = collectionViewFlowLayoutSpacing
        }
    }
    @IBOutlet private var informationView: UIView! {
        didSet {
            informationView.layer.cornerRadius = UIConstants.assessmentCornerRadius
        }
    }
    @IBOutlet private var informationViewForTeacherGrade: UIView! {
        didSet {
            informationView.layer.cornerRadius = UIConstants.assessmentCornerRadius
        }
    }
    @IBOutlet private var questionIsPendingLabel: UILabel!
    @IBOutlet private var gradeInfoForTeacher: UILabel!
    @IBOutlet private var gradeLabel: UILabel!
    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var informationViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Lazy properties

    private lazy var documentInteractionController = UIDocumentInteractionController()
    private lazy var visualEffectView = UIVisualEffectView()

    // MARK: - Private properties
    private var appAlertViewController: AppAlertViewController?
    private var currentSelectedQuestion: AssessmentQuestion?
    private let quizFinishTimePercentage = 0.1
    private let collectionViewFlowLayoutSpacing: CGFloat = 7.0
    private var timer: Timer?
    private var totalDuration = 0.0
    private var questionsViewController: AssessmentQuestionViewController?
    private var assignmentQuestionStateView: AssignmentQuestionStateView?
    private var assessmentDetailOverViewController: AssessmentDetailOverViewViewController?
    private var viewModel: AssessmentDetailsViewModel?
    private var isTimerRunning = false
    private var lastUserIndex: IndexPath? {
        didSet {
            showQuestion(at: lastUserIndex?.row)
            checkToHideNextButton(at: lastUserIndex?.row)
            updateAssessmentDetailOverview(withQuestionAt: lastUserIndex)
            configureAssignmentAnswerState(at: lastUserIndex?.row)
        }
    }
    private var duration = 0.0 {
        didSet {
            counter = duration
        }
    }
    private var counter = 0.0 {
        didSet {
            saveAnswersManagedObjects()
            if counter <= totalDuration * quizFinishTimePercentage,
                viewModel?.status == .open {
                turnOutletsToRed()
            } else {
                changeProgressViewColorForQuestion(at: lastUserIndex?.row ?? 0)
            }
        }
    }

    private var loadingHud: JGProgressHUD?

    // MARK: - Public properties

    var detailState: AssessmentDetailOverViewState = .collapsed

    // MARK: - Clouseres

    var teacherEndUploadingGrades: ((_: AssessmentSubmissionsResponse?) -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        registerNib()
        configureNavigationBar()
        setCollectionViewContentDirection()
        setQuestionsViewController()
        setTotalAndRemainingDuration()
        configureTimerLabel()
        configureTimerStart()
        configureAnsweredQuestionsProgressLabel()
        configureTimeDurationLabelText()
        checkToHideQuestionNumbersCollectionView()
        removeTimerIfNeeded()
        configureAssignmentResults()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        setupDetailOverView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleRemovingDragableView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
    }

    // MARK: - Private functions

    private func refreshViewForTeacherChanges() {
        submitQuestionAnswer(at: lastUserIndex?.row ?? 0)
        setQuestionMark(at: lastUserIndex?.row ?? 0)
        changeProgressViewColorForQuestion(at: lastUserIndex?.row ?? 0)
        setDetailData()
        assessmentDetailOverViewController?.setQuestionsTableViewDetails()
        assessmentDetailOverViewController?.reloadTableView()
        questionNumberCollectionView.reloadData()
    }

    private func removeTimerIfNeeded() {
        guard viewModel?.module == .assignments else { return }
        separator.removeFromSuperview()
        timerStackView.removeFromSuperview()
    }

    private func bindDetailOverviewQuestionSelection() {
        assessmentDetailOverViewController?.goToQuestion = { [weak self] index in
            self?.assessmentDetailOverViewController?.animatTransitionIfNeeded(state: .collapsed, duration: 0.9)
            self?.lastUserIndex?.row = index
            self?.refreshViewForTeacherChanges()
        }
    }

    private func bindDetailsOverviewSubmitAssessmentAnswers() {
        assessmentDetailOverViewController?.submitButtonTapped = { [weak self] in
            self?.assessmentDetailOverViewController?.animatTransitionIfNeeded(state: .collapsed, duration: 0.9)
            self?.finishAssessmentAssignmentForParentAndStudent()
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateRemainingTime), name: .applicationWillEnterForeground, object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .applicationWillEnterForeground, object: nil)
    }

    private func setupDetailOverView() {
        visualEffectView.frame = view.frame
        assessmentDetailOverViewController = StoryboardScene.AssessmentDetailOverview.assessmentDetailOverViewViewController.instantiate()
        setDetailData()
        initAssessmentDetailOverview()
        assessmentDetailOverViewController?.setQuestionsTableViewDetails()
        assessmentDetailOverViewController?.view.clipsToBounds = true
        assessmentDetailOverViewController?.handleGestures()
        bindBlurredBackgroundAnimationHandler()
        configureDetailOverviewState(state: detailState)
        bindDetailOverviewNextQuestionNavigation()
        bindDetailOverviewQuestionSelection()
        bindDetailsOverviewSubmitAssessmentAnswers()
        checkToHideNextButton(at: lastUserIndex?.row)
    }
    
    private func setDetailData() {
        assessmentDetailOverViewController?.module = viewModel?.module ?? .quizzes
        assessmentDetailOverViewController?.numberOfQuestions = viewModel?.numberOfQustions()
        assessmentDetailOverViewController?.assessmentDetails = viewModel?.getAssessmentDetails()
        assessmentDetailOverViewController?.name = viewModel?.assessmentTitle
        assessmentDetailOverViewController?.assessmentStatus = viewModel?.status
        assessmentDetailOverViewController?.studentSubmittedData = viewModel?.submittedStudentData
    }
    
    private func bindDetailOverviewNextQuestionNavigation() {
        assessmentDetailOverViewController?.goToNextQuestion = { [weak self] in
            self?.navigateToNextQuestion()
        }
    }
    
    private func bindBlurredBackgroundAnimationHandler() {
        assessmentDetailOverViewController?.handleBlurAnimation = { [weak self] duration, state in
            self?.detailState = state
            let blurAnimation = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                switch state {
                case .expanded:
                    self?.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self?.visualEffectView.effect = nil
                }
            }
            blurAnimation.startAnimation()
            self?.assessmentDetailOverViewController?.runningAnimations.append(blurAnimation)
        }
    }
    
    private func configureDetailOverviewState(state: AssessmentDetailOverViewState) {
        switch state {
        case .expanded:
            visualEffectView.isUserInteractionEnabled = true
            assessmentDetailOverViewController?.view.layer.zPosition = .infinity
        case .collapsed:
            visualEffectView.isUserInteractionEnabled = false
        }
    }

    private func configureAssignmentResults() {
        guard viewModel?.module == .assignments,
            viewModel?.status == .closed else { return }
        informationView.subviews.forEach {
            $0.removeFromSuperview()
        }
        assignmentQuestionStateView = AssignmentQuestionStateView.instantiate()
        guard let assignmentQuestionStateView = assignmentQuestionStateView
            else { return }
        bindAssignmentQuestionStateView()
        informationView.addSubview(assignmentQuestionStateView)
        informationViewHeightConstraint.isActive = false
        NSLayoutConstraint.activate(
            [
                assignmentQuestionStateView.topAnchor.constraint(equalTo: informationView.topAnchor),
                assignmentQuestionStateView.bottomAnchor.constraint(equalTo: informationView.bottomAnchor),
                assignmentQuestionStateView.leadingAnchor.constraint(equalTo: informationView.leadingAnchor),
                assignmentQuestionStateView.trailingAnchor.constraint(equalTo: informationView.trailingAnchor)
            ]
        )
        configureAssignmentAnswerState(at: lastUserIndex?.row ?? 0)
    }

    private func bindAssignmentQuestionStateView() {
        assignmentQuestionStateView?.falseButtonTappedHandler = {
            self.handleTeacherGradeForAssignment(stateSelected: .incorrect)
        }
        assignmentQuestionStateView?.trueButtonTappedHandler = {
            self.handleTeacherGradeForAssignment(stateSelected: .correct)
        }
    }

    private func handleTeacherGradeForAssignment(stateSelected: AnswerState) {
        viewModel?.editTeacherLocalGradesWith(status: stateSelected, at: self.lastUserIndex?.row ?? 0)
        currentSelectedQuestion?.answerState = stateSelected.rawValue
        viewModel?.setStatusForQuestion(at: lastUserIndex?.row ?? 0, status: stateSelected)
        configureAssignmentAnswerState(at: lastUserIndex?.row ?? 0)
        refreshViewForTeacherChanges()
    }

    private func configureAssignmentAnswerState(at index: Int?) {
        guard
            let index = index,
            let viewModel = viewModel,
            viewModel.module == .assignments,
            viewModel.status == .closed,
            let question = viewModel.getQuestion(at: index)
        else { return }

        assignmentQuestionStateView?.configureAnswerState(
            question.parsedAnswerState,
            questionType: question.type,
            isAnswered: question.isAnswered
        )
    }

    private func checkToHideQuestionNumbersCollectionView() {
        if viewModel?.numberOfQustions() == 1 {
            collectionViewHeightConstraint.constant = 0
        }
    }

    private func initAssessmentDetailOverview() {
        guard let assessmentDetailOverViewController = assessmentDetailOverViewController else { return }
        visualEffectView.frame = view.bounds
        self.view.addSubview(visualEffectView)
        self.addChild(assessmentDetailOverViewController)
        self.view.addSubview(assessmentDetailOverViewController.view)
        repositionDetailOverView()
    }

    private func repositionDetailOverView() {
        guard let assessmentDetailOverViewController = assessmentDetailOverViewController else { return }
        let assessmentDetailViewCollapsedBottomPadding: CGFloat = 5
        let assessmentDetailViewExpandedBottomPadding: CGFloat = 20
        let currentHeight = view.bounds.height
        let currentWidth = view.bounds.width

        if detailState == .collapsed {
            let yPosition = currentHeight -
                assessmentDetailOverViewController.assessmentDetaildragViewHeight -
                assessmentDetailViewCollapsedBottomPadding
            assessmentDetailOverViewController.view.frame = CGRect(
                x: 0,
                y: yPosition,
                width: currentWidth,
                height: currentHeight + assessmentDetailViewExpandedBottomPadding
            )
        } else {
            assessmentDetailOverViewController.view.frame = CGRect(
                x: 0,
                y: view.safeAreaInsets.top,
                width: currentWidth,
                height: currentHeight + assessmentDetailViewExpandedBottomPadding
            )
        }
        visualEffectView.frame = view.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.repositionDetailOverView()
        }
    }
    
    private func handleRemovingDragableView() {
        assessmentDetailOverViewController?.removeFromParent()
        assessmentDetailOverViewController?.view.removeFromSuperview()
        assessmentDetailOverViewController?.willMove(toParent: self)
        visualEffectView.removeFromSuperview()
    }

    private func bindViewModel() {
        viewModel?.invokeErrorHandler = { [weak self] title, message in
            self?.showError(title, message)
        }
        viewModel?.updateAnsweredQuestions = { [weak self] in
            self?.assessmentDetailOverViewController?.assessmentDetails = self?.viewModel?.getAssessmentDetails()
            self?.assessmentDetailOverViewController?.reloadTableView()
            self?.configureAnsweredQuestionsProgressLabel()
            self?.questionNumberCollectionView.reloadData()
        }
    }

    private func showError(_ title: String?, _ message: String?) {
        showAlert(imageName: Images.danger.name, title: title, message: message)
    }

    private func registerNib() {
        questionNumberCollectionView.registerCell(ofType: AssessmentDetailQuestionNumberCollectionViewCell.self)
    }

    private func setCollectionViewContentDirection() {
        questionNumberCollectionView.semanticContentAttribute = LanguageManager.shared.isRightToLeft ? .forceRightToLeft : .forceLeftToRight
    }

    private func setTotalAndRemainingDuration() {
        guard let module = viewModel?.module else { return }
        duration = viewModel?.remainingDuration ?? 0.0
        totalDuration = module == .quizzes
            ? viewModel?.totalDuration ?? 0.0
            : viewModel?.remainingDuration ?? 0.0
    }

    private func configureNavigationBar() {
        setNavigationBarTitle()
        guard let viewModel = viewModel, viewModel.shouldShowFinishButton else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: L10n.Quizzes.finish,
            style: .plain,
            target: self,
            action: #selector(finishAssessmentAssignmentForParentAndStudent)
        )
        let backImage = LanguageManager.shared.isRightToLeft
            ? Asset.Images.backIcon.image.withHorizontallyFlippedOrientation()
            : Asset.Images.backIcon.image
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    private func setNavigationBarTitle() {
        title = viewModel?.assessmentTitle
    }

    private func configureAnsweredQuestionsProgressLabel() {
        guard let assessmentStatus = viewModel?.status,
            let progress = viewModel?.answeredQuestionsRatio else { return }
        progressView.setProgress(progress, animated: true)
        switch assessmentStatus {
        case .open:
            progressLabel.text = viewModel?.getNumberOfAnsweredQuestionsText()
        case .closed:
            progressLabel.text = L10n.Quizzes.thisQuestionGrade
        }
    }
    
    private func configureTimerLabel() {
        guard let assessmentStatus = viewModel?.status,
            viewModel?.module == .quizzes else { return }
        timerLabel.numberOfLines = 2
        timerLabel.lineBreakMode = .byTruncatingTail
        switch assessmentStatus {
        case .closed:
            disableTimerForClosedQuiz()
        case .open:
            let minute = Int(floor(counter / 60))
            let second = Int(floor(counter.truncatingRemainder(dividingBy: 60)))
            timerLabel.text = viewModel?.getCounterString(minutes: minute, seconds: second)
        }
    }

    private func configureTimeDurationLabelText() {
        guard let assessmentStatus = viewModel?.status,
            viewModel?.module == .quizzes else { return }
        switch assessmentStatus {
        case .open:
            timerDurationLabel.text = L10n.Quizzes.timeDuration
        case .closed:
            timerDurationLabel.text = L10n.Quizzes.yourGrade
        }
    }

    private func disableTimerForClosedQuiz() {
        progressView.isHidden = true
        progressViewBorder.isHidden = true
        timerDurationLabel.textColor = Colors.grey90.color
        timerLabel.text = viewModel?.questionMarkText(at: 0)
    }

    private func setQuestionsViewController() {
        guard let questionsViewCtrl = children.first as? AssessmentQuestionViewController
            else { return }
        questionsViewController = questionsViewCtrl
        questionsViewController?.delegate = self
        questionsViewController?.setAssessmentStatus(viewModel?.status)
        questionsViewController?.setCurrentModule(module: viewModel?.module ?? .quizzes)
        if viewModel?.numberOfQustions() ?? 0 > 0 {
            lastUserIndex = IndexPath(row: 0, section: 0)
        }
    }

    private func checkToHideNextButton(at index: Int?) {
        guard let index = index else { return }
        viewModel?.isLastQuestion(at: index) == true
            ? assessmentDetailOverViewController?.hideNextButton()
            : assessmentDetailOverViewController?.showNextButton()
    }

    private func updateAssessmentDetailOverview(withQuestionAt indexPath: IndexPath?) {
        guard let index = indexPath?.row else { return }
        assessmentDetailOverViewController?.isLastQuestionSelected = viewModel?.isLastQuestion(at: index) ?? false
    }

    private func showQuestion(at index: Int?) {
        guard let index = index,
            let question = viewModel?.getQuestion(at: index) else { return }
        questionsViewController?.showQuestion(question)
        questionNumberCollectionView.reloadData()
        scroll(questionNumberCollectionView, to: lastUserIndex)
    }

    private func navigateToNextQuestion() {
        guard let row = lastUserIndex?.row else { return }
        if viewModel?.isLastQuestion(at: row) == true {
            assessmentFinishedForParentAndStudent(
                imageName: Images.danger.name,
                title: L10n.Quizzes.finishMessage,
                message: nil
            )
        } else {
            let indexPath = IndexPath(row: row + 1, section: 0)
            setQuestionMark(at: indexPath.row)
            changeProgressViewColorForQuestion(at: indexPath.row)
            if questionNumberCollectionView.indexPathsForVisibleItems.contains(indexPath) {
                submitQuestionAnswer(at: row)
                lastUserIndex = indexPath
            }
        }
    }

    private func submitQuestionAnswer(at index: Int?) {
        guard let viewModel = viewModel, let index = index, viewModel.status == .open else { return }
        viewModel.submitQuestionAnswer(at: index)
    }

    private func assessmentFinishedForParentAndStudent(
        imageName: String,
        title: String?,
        message: String?,
        timesOut: Bool = false
    ) {
        dismissPresentedIfNeeded { [weak self] in
            self?.appAlertViewController = self?.showAndReturnAlert(
                imageName: imageName,
                title: title,
                message: message,
                primaryButtonTitle: L10n.Global.Actions.ok,
                dismissButtonTitle: L10n.Global.Actions.cancel
            ) { [weak self] in
                self?.dismiss(animated: true) {
                    guard ReachabilityAppDelegate.connectionState == .connected else {
                        self?.handleFininshAssessmentInOfflineMode()
                        return 
                    }
                    self?.showLoadingIndicator()
                    self?.handleEndingAssessment()
                }
            }
            self?.handleTimeOutOfQuiz(timesOut: timesOut, alert: self?.appAlertViewController)
        }
    }


    private func handleEndingAssessment() {
        submitQuestionAnswer(at: lastUserIndex?.row)
        let assessmentSynchronization = AssessmentSynchronization()
        assessmentSynchronization.synchronizationCompletionHandler = {
            self.viewModel?.finishAssessment { error in
                self.hideLoadingIndicator()
                self.handleFinishAssessmentSuccess()
            }
        }
        assessmentSynchronization.startSynchronizationForQuiz(id: viewModel?.assissmentID ?? 0)
    }

    private func handleFinishAssessmentSuccess() {
        if let presentedViewCtrl = presentedViewController {
            presentedViewCtrl.dismiss(animated: true) {
                self.showSuccessfulSubmit()
            }
        } else {
            showSuccessfulSubmit()
        }
    }

    private func showSuccessfulSubmit() {
        self.showAlert(
            imageName: Images.imgSuccess.name,
            title: self.viewModel?.submittedAlertTitle ?? "",
            message: self.viewModel?.submittedAlertMessage ?? ""
        ) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func handleFininshAssessmentInOfflineMode() {
        let submittedMessage = self.viewModel?.submittedAlertMessage ?? ""
        let internetIssueMessage = L10n.Quizzes.submittedAlertConnectionMessage
        appAlertViewController?.dismiss(animated: true) {
            self.showAlert(
                imageName: Images.imgSuccess.name,
                title: self.viewModel?.submittedAlertTitle ?? "",
                message: "\(submittedMessage). \(internetIssueMessage)"
            ) {
                self.submitQuestionAnswer(at: self.lastUserIndex?.row)
                self.viewModel?.finishAssessment()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func handleTimeOutOfQuiz(timesOut: Bool, alert: AppAlertViewController?) {
        if timesOut {
            submitQuestionAnswer(at: lastUserIndex?.row)
            alert?.configureOneButton(buttonTitle: L10n.Quizzes.submitButtonTitle) {
                alert?.startPrimaryButtonLoading()
                self.handleEndingAssessment()
            }
        }
    }

    private func dismissPresentedIfNeeded(completion: @escaping () -> Void) {
        guard let presentedViewCtrl = presentedViewController else {
            completion()
            return
        }
        presentedViewCtrl.dismiss(animated: true) {
            completion()
        }
    }

    private func setQuestionMark(at index: Int) {
        guard viewModel?.module == .quizzes, viewModel?.status == .closed else { return }
        timerLabel.text = viewModel?.questionMarkText(at: index)
    }

    private func runTimer() {
        counter -= 1
        if counter == 0 {
            assessmentFinishedForParentAndStudent(
                imageName: Images.timeOut.name,
                title: L10n.Quizzes.timeOutTitle,
                message: L10n.Quizzes.timeOutDescription,
                timesOut: true
            )
        }
        let minute = Int(floor(counter / 60))
        let second = Int(floor(counter.truncatingRemainder(dividingBy: 60)))
        timerLabel?.text = viewModel?.getCounterString(minutes: minute, seconds: second)

        if counter <= 0.0 {
            isTimerRunning = false
            timerLabel?.text = viewModel?.getCounterString(minutes: 0, seconds: 0)
            timer?.invalidate()
        }
    }

    private func saveAnswersManagedObjects() {
        guard counter > 0, counter.truncatingRemainder(dividingBy: 10) == 0 else { return }
        viewModel?.saveAnswersManagedObjects()
    }

    private func share(url: URL) {
        if !(UIApplication.topViewController() is AppAlertViewController) {
            documentInteractionController.delegate = self
            documentInteractionController.url = url
            documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
            documentInteractionController.name = url.localizedName ?? url.lastPathComponent
            documentInteractionController.presentPreview(animated: true)
        }
    }

    // MARK: - Public functions

    func setViewModel(_ viewModel: AssessmentDetailsViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Selectors
extension AssessmentDetailsViewController {
    @objc
    private func updateRemainingTime() {
        guard viewModel?.module == .quizzes,
            let remainingTime = viewModel?.getUpdatedRemainingTimeInSeconds()
            else { return }
        switch remainingTime {
        case 0 where viewModel?.status == .open:
            timer?.invalidate()
            timerLabel.text = viewModel?.getCounterString(minutes: 0, seconds: 0)
            assessmentFinishedForParentAndStudent(
                imageName: Images.timeOut.name,
                title: L10n.Quizzes.timeOutTitle,
                message: L10n.Quizzes.timeOutDescription,
                timesOut: true
            )
        default:
            counter = Double(remainingTime)
        }
    }

    @objc private func finishAssessmentAssignmentForParentAndStudent() {
        assessmentFinishedForParentAndStudent(
            imageName: Images.danger.name,
            title: L10n.Quizzes.finishMessage,
            message: nil
        )
    }

    @objc private func backButtonTapped() {
        handleBackClickForParentAndStudent()
    }

    private func handleBackClickForParentAndStudent() {
        switch viewModel?.module {
        case .quizzes:
            finishAssessmentAssignmentForParentAndStudent()
        case .assignments:
            pauseAssignment()
        default:
            return
        }
    }
}

// MARK: - Pause assignment
extension AssessmentDetailsViewController {
    private func pauseAssignment() {
        dismissPresentedIfNeeded { [weak self] in
            self?.showAlert(
                imageName: Images.danger.name,
                title: L10n.Assignment.pauseAlertTitle,
                message: L10n.Assignment.pauseAlertMessage,
                primaryButtonTitle: L10n.Assignment.pauseAlertPauseButtonTitle,
                dismissButtonTitle: L10n.Assignment.pauseAlertCancelButtonTitle
            ) {
                self?.dismiss(animated: true) {
                    self?.submitQuestionAnswer(at: self?.lastUserIndex?.row)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AssessmentDetailsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let dimension: CGFloat = 35
        return CGSize(width: dimension, height: dimension)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        submitQuestionAnswer(at: lastUserIndex?.row)
        lastUserIndex = indexPath
        setQuestionMark(at: indexPath.row)
        collectionView.reloadData()
        scroll(questionNumberCollectionView, to: indexPath)
        changeProgressViewColorForQuestion(at: indexPath.row)
    }

    func scroll(_ collectionView: UICollectionView, to indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        collectionView.scrollToItem(
            at: indexPath,
            at: .left,
            animated: true
        )
    }

    func changeProgressViewColorForQuestion(at index: Int) {
        guard let question = viewModel?.getQuestion(at: index), viewModel?.module == .quizzes else { return }
        currentSelectedQuestion = question
        changeInformationViewState(question, selectedIndex: index)
    }
}

// MARK: - UICollectionViewDataSource
extension AssessmentDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfQustions() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { return UICollectionViewCell() }
        let cell: AssessmentDetailQuestionNumberCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
        let questionNumber = indexPath.row + 1
        switch viewModel.module {
        case .assignments where viewModel.status == .closed:
            cell.configureAssignmentAnswer(
                with: questionNumber,
                viewModel.questionState(at: indexPath.row),
                isSelected: indexPath == lastUserIndex
            )
        default:
            cell.configure(
                with: questionNumber,
                isSelected: indexPath == lastUserIndex,
                isAnswered: viewModel.isQuestionAnswered(at: indexPath.row),
                isWrongAnswer: viewModel.isWrongAnswer(at: indexPath.row),
                isRightAnswer: viewModel.isRightAnswer(at: indexPath.row),
                question: viewModel.getQuestion(at: indexPath.row)
            )
        }
        return cell
    }
}

// MARK: Counter handling
extension AssessmentDetailsViewController {
    private func configureTimerStart() {
        if viewModel?.status == .open {
            startTimer()
        }
    }

    func startTimer() {
        if !isTimerRunning {
            timer = Timer.scheduledTimer(
                withTimeInterval: 1,
                repeats: true
            ) { [weak self] _ in
                self?.runTimer()
            }
        }
        isTimerRunning = true
    }
    
    private func turnOutletsToRed() {
        guard viewModel?.module == .quizzes else { return }
        progressLabel.textColor = .red
        timerLabel.textColor = .red
        separator.backgroundColor = .red
        informationView.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        progressView.progressTintColor = .red
        progressViewBorder.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        progressViewBorder.layer.borderColor = UIColor.red.cgColor
        timerDurationLabel.textColor = .red
    }
    
    private func turnOutletsToBlue() {
        guard viewModel?.module == .quizzes else { return }
        progressLabel.textColor = .black
        timerLabel.textColor = Asset.Colors.sendButtonColor.color
        separator.backgroundColor = Asset.Colors.sendButtonColor.color
        informationView.backgroundColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(0.1)
        progressView.progressTintColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(0.3)
        progressViewBorder.backgroundColor = Asset.Colors.lightAccentColor.color
        progressViewBorder.layer.borderColor = Asset.Colors.sendButtonColor.color.withAlphaComponent(0.3).cgColor
        timerDurationLabel.textColor = Asset.Colors.darkGreyColor.color
    }

    private func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }
}

// MARK: - Handle info tab view from open to closed
extension AssessmentDetailsViewController {
    private func setLabelWithAttribute(_ text: String, _ attributes: [NSAttributedString.Key: Any], _ label: UILabel) {
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes as [NSAttributedString.Key: Any])
        label.attributedText = attributedString
    }
    
    private func changeInformationViewState(_ question: AssessmentQuestion?, selectedIndex: Int) {
        guard let question = question else { return }
        handleInformationViewForStudentAndParent(question)
    }

    private func handleInformationViewForStudentAndParent(_ question: AssessmentQuestion?) {
        informationViewForTeacherGrade.isHidden = true
        informationView.isHidden = false
        switch question?.studentMark {
        case Double.zero:
            changeInformationViewColor(color: .red)
        case question?.mark:
            changeInformationViewColor(color: Colors.green.color)
        case nil:
            turnOutletsToBlue()
        default:
            changeInformationViewColor(color: .orange)
        }
    }
    
    private func changeInformationViewColor(color: UIColor) {
        informationView.backgroundColor = color.withAlphaComponent(0.1)
        separator.backgroundColor = color
        timerLabel.textColor = color
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension AssessmentDetailsViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// MARK: - AssessmentQuestionsDelegate
extension AssessmentDetailsViewController: AssessmentQuestionsDelegate {
    func teacherAddOrEditComment(comment: String) {
        viewModel?.editTeacherLocalGradesWith(teacherComment: comment, at: self.lastUserIndex?.row ?? 0)
        currentSelectedQuestion?.comment = comment
        refreshViewForTeacherChanges()
    }

    func didAnswerQuestion(with questionID: Int?) {
        viewModel?.updateQuestionAnsweredStatus(questionID)
    }

    func didAttachFile(with url: URL, for questionID: Int?) {
        viewModel?.addAttachment(url, questionID)
        viewModel?.updateQuestionAnsweredStatus(questionID)
    }

    func didDeleteAttachedFile(for questionID: Int?) {
        viewModel?.cancelUploadRequest(questionID)
        viewModel?.deleteAttachment(questionID)
        viewModel?.updateQuestionAnsweredStatus(questionID)
    }

    func didOpenAttachment(with url: URL?, needsDownload: Bool, questionID: Int?) {
        guard let url = url else { return }
        if needsDownload {
            viewModel?.downloadAttachemt(
                with: url,
                delegate: AttachmentDownloader(attachmentID: questionID, delegate: self)
            )
        } else {
            share(url: url)
        }
    }
}

// MARK: - AttachmentDownloaderDelegate
extension AssessmentDetailsViewController: AttachmentDownloaderDelegate {
    func didDownloadAttachment(at url: URL, attachmentID: Int?) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.setAttachedFileLocalURL(url: url, questionID: attachmentID)
            self?.share(url: url)
        }
    }

    func didUpdateProgress(_ progress: Double, for questionID: Int?) {
        questionsViewController?.updateDownloadProgress(questionID: questionID, progress: progress)
    }
}
