// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import HandySwift
import UIKit
import LanguageManager_iOS

protocol AssessmentQuestionsDelegate: class {
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
            if counter <= totalDuration * quizFinishTimePercentage,
                viewModel?.status == .open {
                turnOutletsToRed()
            } else {
                changeProgressViewColorForQuestion(at: lastUserIndex?.row ?? 0)
            }
        }
    }

    // MARK: - Public properties

    var isClosed = false
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
        setupDetailOverView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleRemovingDragableView()
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

    private func setupDetailOverView() {
        visualEffectView.frame = view.frame
        assessmentDetailOverViewController =
            StoryboardScene.AssessmentDetailOverview.assessmentDetailOverViewViewController.instantiate()
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

    private func handleTeacherGradeForAssignment(stateSelected: AssessmentQuestion.AnswerState) {
        viewModel?.editTeacherLocalGradesWith(status: stateSelected, at: self.lastUserIndex?.row ?? 0)
        currentSelectedQuestion?.answerState = stateSelected
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
            question.answerState,
            teacherSelction: viewModel.getTeacherLocalGradesForQuestion(at: index)?.status,
            questionType: question.type,
            isAnswered: question.isAnswered
        )
        assignmentQuestionStateView?.setQuestionComment(
            question.comment,
            question.answerState,
            questionType: question.type,
            isAnswered: question.isAnswered,
            teacherSelction: viewModel.getTeacherLocalGradesForQuestion(at: index)?.status
        )
    }

    private func checkToHideQuestionNumbersCollectionView() {
        if viewModel?.numberOfQustions() == 1 {
            collectionViewHeightConstraint.constant = 0
        }
    }

    private func initAssessmentDetailOverview() {
        guard let assessmentDetailOverViewController = assessmentDetailOverViewController else { return }
        visualEffectView.frame = view.frame
        self.view.addSubview(visualEffectView)
        self.addChild(assessmentDetailOverViewController)
        self.view.addSubview(assessmentDetailOverViewController.view)
        let assessmentDetailViewCollapsedBottomPadding: CGFloat = 5
        let assessmentDetailViewExpandedBottomPadding: CGFloat = 20
        let yPosition = UIScreen.main.bounds.height -
            assessmentDetailOverViewController.assessmentDetaildragViewHeight -
            assessmentDetailViewCollapsedBottomPadding
        assessmentDetailOverViewController.view.frame = CGRect(
            x: 0,
            y: yPosition,
            width: view.bounds.width,
            height: UIScreen.main.bounds.height + assessmentDetailViewExpandedBottomPadding
        )
    }
    
    private func handleRemovingDragableView() {
        assessmentDetailOverViewController?.removeFromParent()
        assessmentDetailOverViewController?.view.removeFromSuperview()
        assessmentDetailOverViewController?.willMove(toParent: self)
        visualEffectView.removeFromSuperview()
    }

    private func bindViewModel() {
        viewModel?.invokeErrorHandler = { [weak self] title, message in
            self?.appAlertViewController?.dismiss(animated: true) {
                self?.showError(title, message)
            }
        }
        viewModel?.updateAnsweredQuestions = { [weak self] in
            self?.assessmentDetailOverViewController?.assessmentDetails = self?.viewModel?.getAssessmentDetails()
            self?.assessmentDetailOverViewController?.reloadTableView()
            self?.configureAnsweredQuestionsProgressLabel()
            self?.questionNumberCollectionView.reloadData()
        }
    }

    private func showError(_ title: String?, _ message: String?) {
        showAlert(imageName: "danger", title: title, message: message)
    }
    
    private func registerNib() {
        let questionNumberCollectionViewCellNib = UINib(nibName: Nib.assessmentDetailQuestionTableViewCell.rawValue, bundle: nil)
        questionNumberCollectionView.register(
            questionNumberCollectionViewCellNib,
            forCellWithReuseIdentifier: "AssessmentDetailQuestionNumberCollectionViewCell"
        )
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
            title: "quizzes.finish".localiz(),
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
            progressLabel.text = "quizzes.thisQuestionGrade".localiz()
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
            timerDurationLabel.text = "quizzes.timeDuration".localiz()
        case .closed:
            timerDurationLabel.text = "quizzes.yourGrade".localiz()
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
    }

    private func navigateToNextQuestion() {
        guard let row = lastUserIndex?.row else { return }
        if viewModel?.isLastQuestion(at: row) == true {
            assessmentFinishedForParentAndStudent(
                imageName: Images.danger.name,
                title: "quizzes.finishMessage".localiz(),
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
    
    private func assessmentFinishedForTeacher() {
        guard let viewModel = viewModel else { return }
        if viewModel.isAllQuestionsGradedFromTeacher() {
            showAlertForSureToUploadGrades()
        } else {
            dismissPresentedIfNeeded { [weak self] in
                self?.showAlert(
                    imageName: Images.danger.name,
                    title: "",
                    message: "quizzes.notAllGradedError".localiz()
                ) {
                    self?.dismiss(animated: true)
                }
            }
        }
    }

    private func assessmentFinishedForParentAndStudent(
        imageName: String,
        title: String?,
        message: String?,
        timesOut: Bool = false
    ) {
        dismissPresentedIfNeeded { [weak self] in
            let alert = self?.showAndReturnAlert(
                imageName: imageName,
                title: title,
                message: message,
                primaryButtonTitle: L10n.Global.Actions.ok,
                dismissButtonTitle: L10n.Global.Actions.cancel
            ) { [weak self] in
                self?.dismiss(animated: true) {
                    let message = self?.viewModel?.submittedAlertMessage ?? ""
                    self?.showAlert(
                        imageName: Images.imgSuccess.name,
                        title: self?.viewModel?.submittedAlertTitle ?? "",
                        message: message
                    ) {
                        self?.submitQuestionAnswer(at: self?.lastUserIndex?.row)
                        self?.viewModel?.finishAssessment { _ in
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            self?.handleTimeOutOfQuiz(timesOut: timesOut, alert: alert)
        }
    }

    private func handleTimeOutOfQuiz(timesOut: Bool, alert: AppAlertViewController?) {
        if timesOut {
            submitQuestionAnswer(at: lastUserIndex?.row)
            alert?.configureOneButton(buttonTitle: L10n.Quizzes.submitButtonTitle) {
                alert?.startPrimaryButtonLoading()
                self.viewModel?.finishAssessment { [weak self] error in
                    alert?.stopPrimaryButtonLoading()
                    if error == nil {
                        self?.navigationController?.popViewController(animated: true)
                        alert?.dismiss(animated: true)
                    }
                }
            }
        }
    }

    private func dismissPresentedIfNeeded(completion: @escaping () -> Void) {
        guard let presentedViewController = presentedViewController else {
            completion()
            return
        }
        presentedViewController.dismiss(animated: true) {
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
                imageName: "timeOut",
                title: "quizzes.timeOutTitle".localiz(),
                message: "quizzes.timeOutDescription".localiz(),
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
    @objc private func updateRemainingTime() {
        guard viewModel?.module == .quizzes,
            let remainingTime = viewModel?.getUpdatedRemainingTimeInSeconds()
            else { return }
        switch remainingTime {
        case 0 where viewModel?.status == .open:
            timer?.invalidate()
            timerLabel.text = viewModel?.getCounterString(minutes: 0, seconds: 0)
            assessmentFinishedForParentAndStudent(
                imageName: Images.timeOut.name,
                title: "quizzes.timeOutTitle".localiz(),
                message: "quizzes.timeOutDescription".localiz(),
                timesOut: true
            )
        default:
            counter = Double(remainingTime)
        }
    }

    @objc private func finishAssessmentAssignmentForParentAndStudent() {
        assessmentFinishedForParentAndStudent(
            imageName: Images.danger.name,
            title: "quizzes.finishMessage".localiz(),
            message: nil
        )
    }

    @objc private func finishAssessmentAssignmentForTeacher() {
        assessmentFinishedForTeacher()
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

    private func handleBackClickForTeahcer() {
        guard let viewModel = viewModel else { return }
        if viewModel.isAllQuestionsGradedFromTeacher() {
            showAlertForFinishAllQuestionsCase()
        } else {
            showAlertForNotFinishedQuestions()
        }
    }

    private func showAlertForFinishAllQuestionsCase() {
        appAlertViewController = showAndReturnAlert(
            imageName: Images.danger.name,
            title: nil,
            message: "quizzes.gradeWontSaved".localiz(),
            primaryButtonTitle: "quizzes.submitButtonTitleForTeacherAlert".localiz(),
            dismissButtonTitle: "quizzes.goBackAnyway".localiz(),
            secondryButtonCompletionHandler: {
                self.dismiss(animated: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            }, primaryButtonCompletionHandler: {
                self.appAlertViewController?.startPrimaryButtonLoading()
            }
        )
    }

    private func showAlertForSureToUploadGrades() {
        appAlertViewController = showAndReturnAlert(
            imageName: Images.danger.name,
            title: nil,
            message: "quizzes.markAsCheckedAlert".localiz(),
            primaryButtonTitle: "app.yes".localiz(),
            dismissButtonTitle: "app.cancel".localiz()) {
            self.appAlertViewController?.startPrimaryButtonLoading()
        }
    }

    private func showAlertForNotFinishedQuestions() {
        appAlertViewController = showAndReturnAlert(
            imageName: Images.danger.name,
            title: nil,
            message: "quizzes.gradeWontSaved".localiz(),
            primaryButtonTitle: "quizzes.continueGrading".localiz(),
            dismissButtonTitle: "quizzes.goBackAnyway".localiz(),
            secondryButtonCompletionHandler: {
                self.dismiss(animated: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            }, primaryButtonCompletionHandler: {
                self.dismiss(animated: true)
            }
        )
    }
}

// MARK: - Pause assignment
extension AssessmentDetailsViewController {
    private func pauseAssignment() {
        dismissPresentedIfNeeded { [weak self] in
            self?.showAlert(
                imageName: Images.danger.name,
                title: "assignment.pauseAlertTitle".localiz(),
                message: "assignment.pauseAlertMessage".localiz(),
                primaryButtonTitle: "assignment.pauseAlertPauseButtonTitle".localiz(),
                dismissButtonTitle: "assignment.pauseAlertCancelButtonTitle".localiz()
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
        changeProgressViewColorForQuestion(at: indexPath.row)
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

    private func handleInformationViewForTeacher(studentMark: Double?, questionMark: Double?, selectedIndex: Int) {
        handleDesignForInformationViewForTeacher()
        guard let questionMark = questionMark else { return }
        if let studentMark = studentMark {
            setViewForGradedQuestionForTeacher(studentMark: studentMark, questionMark: questionMark)
        } else {
            setViewForNotGradedQuestionForTeacher(questionMark: questionMark)
        }
    }

    private func setViewForGradedQuestionForTeacher(studentMark: Double, questionMark: Double) {
        questionIsPendingLabel.isHidden = true
        gradeInfoForTeacher.text = "quizzes.thisQuestionGrade".localiz()
        let grade = Grade(currentMark: studentMark, totalMark: questionMark)
        gradeLabel.text = grade.description
    }

    private func setViewForNotGradedQuestionForTeacher(questionMark: Double) {
        var questionMarkString = ""
        if let localizedQuestionGrade = NumberFormatter.getDecimalFormattedString(fromDouble: questionMark) {
            questionMarkString = localizedQuestionGrade
        }
        questionIsPendingLabel.isHidden = false
        questionIsPendingLabel.text = "assignment.questionIsPending".localiz()
        gradeInfoForTeacher.text = "\("quizzes.pleaseEnterGrade".localiz()) : \(questionMarkString) \("quizzes.points".localiz())"
        let gradeLabelText = Language.currentLanguage == .arabic ?
            "\(questionMarkString) / -":
            "- / \(questionMarkString)"
        gradeLabel.text = gradeLabelText
    }

    private func handleDesignForInformationViewForTeacher() {
        informationViewForTeacherGrade.isHidden = false
        informationView.isHidden = true
        informationViewForTeacherGrade.addShadow(
            with: .lightGray,
            offset: CGSize(
                width: UIConstants.oneShadowWidth,
                height: UIConstants.oneShadowHeight
            ),
            radius: UIConstants.threeShadowRadius,
            opacity: Float(UIConstants.shadowOpacity)
        )
        informationViewForTeacherGrade.layer.cornerRadius = 26
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
