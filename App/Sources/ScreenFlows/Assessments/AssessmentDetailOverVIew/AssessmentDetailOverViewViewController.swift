// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import HandySwift
import UIKit
import LanguageManager_iOS

protocol AssessmentDetailsDelegate: class {
    func didFinishAssessment(with id: Int?)
}

enum QuestionStatus {
    case correct
    case wrong
    case needsImprovement
    case notGraded
}

class AssessmentDetailOverViewViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private var intructionsAttachedLabel: UILabel!
    @IBOutlet private var detailMainView: UIView!
    @IBOutlet private var detailOverView: UIView!
    @IBOutlet private var quiInfoView: UIView!
    @IBOutlet private var dragViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var gradeInfoView: UIView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var assessmentNameLabel: UILabel!
    @IBOutlet private var dueLabel: UILabel!
    @IBOutlet private var numberOfQuestionsLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var assessmentGradeLabel: UILabel!
    @IBOutlet private var gradeLabel: UILabel!
    @IBOutlet private var yourGradeLabel: UILabel!
    @IBOutlet private var gradeHintLabel: UILabel!
    @IBOutlet private var submitButton: UIButton! {
        didSet {
            submitButton.setTitle("quizzes.submitButtonTitle".localiz(), for: .normal)
        }
    }
    @IBOutlet private var viewAllLabel: UILabel! {
        didSet {
            viewAllLabel.text = module == .quizzes
                ? L10n.Quizzes.viewAll
                : L10n.Quizzes.viewDescription
        }
    }
    @IBOutlet private var dragView: UIView! {
        didSet {
            dragView.isHidden = false
            dragView.backgroundColor = Asset.Colors.lightAccentColor.color
            dragView.setFrameShape(.circular)
        }
    }
    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        animatTransitionIfNeeded(state: .collapsed, duration: 0.9)
    }
    
    @IBOutlet private var nextButton: UIButton! {
        didSet {
            nextButton.setTitle("quizzes.next".localiz(), for: .normal)
            var backImage = UIImage(asset: Images.nextIcon)
            backImage = Language.currentLanguage == .arabic ?
                backImage?.withHorizontallyFlippedOrientation():
            backImage
            nextButton.setImage(backImage, for: .normal)
        }
    }

    @IBAction private func nextButtonTapped(_ sender: UIButton) {
        goToNextQuestion?()
    }

    @IBOutlet private var questionsTableView: UITableView! {
        didSet {
            questionsTableView.dataSource = self
            questionsTableView.delegate = self
        }
    }

    // MARK: - Private properties

    private let dragViewExpandedWidth: CGFloat = 75
    private let dragViewCollapsedWidth: CGFloat = 39

    // MARK: - Public properties

    var goToNextQuestion: (() -> Void)?
    var submitButtonTapped: (() -> Void)?
    var goToQuestion: ((Int) -> Void)?
    let assessmentDetailOverViewHeight: CGFloat = 0.92 * UIScreen.main.bounds.height
    let assessmentDetaildragViewHeight: CGFloat = 0.08 * UIScreen.main.bounds.height
    var assessmentDetailOverViewVisible = false
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    var numberOfQuestions: Int?
    var name: String?
    var assessmentDetails: AssessmentDetails?
    var assessmentStatus: AssessmentStatus?
    var questionStatus: QuestionStatus?
    var studentSubmittedData: AssessmentSubmittedStudents?
    var handleBlurAnimation: ((TimeInterval, AssessmentDetailOverViewState) -> Void)?
    var module: AssessmentsOverViewViewModel.Module = .quizzes
    var isLastQuestionSelected = false {
        didSet {
            isLastQuestionSelected ? hideNextButton() : showNextButton()
        }
    }
    var nextState: AssessmentDetailOverViewState {
        return assessmentDetailOverViewVisible ? .collapsed : .expanded
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.isHidden = true
        registerNib()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        nextButton.semanticContentAttribute = Language.currentLanguage == .english ? .forceRightToLeft : .unspecified
    }

    // MARK: - Private functions

    private func registerNib() {
        questionsTableView.registerCell(ofType: AssessmentDetailOverviewInstructionsTableViewCell.self)
        questionsTableView.registerCell(ofType: AssessmentDetailOverViewQuestionsTableViewCell.self)
    }

    private func formatDueDate(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = GlobalConstants.dateTimeFormat
        if let date = dateFormatter.date(from: date) {
            let dueDate = date.formatted(with: GlobalConstants.dueDateFormat)
            dueLabel.text = "\("quizzes.due".localiz()) \(dueDate)"
        }
    }

    private func calculateDuration(duration: Int?) -> String {
        guard let durationInSeconds = duration else { return "" }
        return "\("quizzes.duration".localiz()) \(TimeCalculator.sharedInstance.getLoacalizedMinutesText(minutes: durationInSeconds / 60))"
    }

    private func configureQuestionTableViewCell (
        at indexPath: IndexPath,
        withCell cell: AssessmentDetailOverViewQuestionsTableViewCell,
        withQuestion question: AssessmentQuestion,
        tableView: UITableView
    ) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = GlobalConstants.datePreviewFormat
        cell.configure(
            assessmentName: getQuestionName(indexPath: indexPath),
            numberOfPoints: numberOfPointsText(of: question),
            questionStatus: isQuestionAnswered(at: indexPath.row),
            mark: questionMarkText(at: indexPath.row),
            assessmentStatus: assessmentStatus ?? .open,
            questionMarkStatus: getQuestionMarkStatus(
                question: assessmentDetails?.questions?[indexPath.row]
            ),
            module: module,
            answerStatus: assessmentDetails?.questions?[indexPath.row].answerState ?? .notReviewed
        )
        return cell
    }

    private func isQuestionAnswered(at index: Int) -> Bool {
        return assessmentDetails?.questions?[index].isAnswered ?? false
    }

    private func handleCornerRadius(duration: TimeInterval, state: AssessmentDetailOverViewState) {
        let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) { [weak self] in
            self?.view.layer.cornerRadius = 19
        }
        cornerRadiusAnimator.startAnimation()
        runningAnimations.append(cornerRadiusAnimator)
    }
    
    private func handleBlur(duration: TimeInterval, state: AssessmentDetailOverViewState) {
        handleBlurAnimation?(duration, state)
    }

    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    private func continueInternactiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    private func setLabelWithAttribute(_ text: String, _ attributes: [NSAttributedString.Key: Any], _ label: UILabel) {
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes as [NSAttributedString.Key: Any])
        label.attributedText = attributedString
    }

    private func getQuestionMarkStatus(question: AssessmentQuestion?) -> QuestionStatus {
        switch question?.studentMark {
        case Double.zero:
            questionStatus = .wrong
        case question?.mark:
            questionStatus = .correct
        case nil:
            questionStatus = .notGraded
        default:
            questionStatus = .needsImprovement
        }
        guard let status = questionStatus else { return .correct }
        return status
    }

    private func getStudentTotalMark(assessmentDetails: AssessmentDetails?) -> String? {
        var totalMark = 0.0
        totalMark = assessmentDetails?.studentTotalMark ?? 0
        guard let studentMark = assessmentDetails?.mark else { return nil }

        let grade = Grade(currentMark: totalMark, totalMark: studentMark)
        return grade.description
    }

    private func getTotalMarkForTeacher() -> Double {
        var result = 0.0
        guard let questions = assessmentDetails?.questions else { return 0 }
        for question in questions {
            result += question.studentMark ?? 0
        }
        return result
    }

    // MARK: - Public functions

    func setQuestionsTableViewDetails() {
        guard let assessment = assessmentDetails else { return }
        numberOfQuestionsLabel.text = assessment.localizedNumberOfQuestionsText
        formatDueDate(date: assessment.availableTo ?? "")
        configureSubmitButton(assessmentStatus)
        configureGradeInfoView(assessment)
        intructionsAttachedLabel.text = assessment.instructions?.isValid == true
            ? "quizzes.instructionsAttached".localiz()
            : nil
        assessmentNameLabel.text = assessment.title
        durationLabel.isHidden = false
        durationLabel.text = calculateDuration(duration: assessment.duration)
    }

    private func configureSubmitButton(_ status: AssessmentStatus?) {
        if assessmentStatus == .closed {
            submitButton.removeFromSuperview()
        }
    }

    private func configureGradeInfoView(_ assessmentDetails: AssessmentDetails) {
        guard module == .quizzes else {
            gradeInfoView.removeFromSuperview()
            return
        }
        assessmentGradeLabel.text = "quizzes.quizGrade".localiz()
        gradeLabel.text = getStudentTotalMark(assessmentDetails: assessmentDetails)
        gradeInfoView.isHidden = assessmentStatus == .open ? true : false
        yourGradeLabel.isHidden = true
        gradeHintLabel.isHidden = true
    }

    func reloadTableView() {
        questionsTableView.reloadData()
    }

    func handleGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDetailTap))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDetailPan))
        detailMainView.addGestureRecognizer(tapGestureRecognizer)
        detailMainView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func handledragViewExpansion(state: AssessmentDetailOverViewState) {
        switch state {
        case .expanded:
            dragViewWidthConstraint.constant = dragViewExpandedWidth
            viewAllLabel.isHidden = true
            closeButton.isHidden = false
            intructionsAttachedLabel.isHidden = true
            hideNextButton()
        case .collapsed:
            dragViewWidthConstraint.constant = dragViewCollapsedWidth
            viewAllLabel.isHidden = false
            closeButton.isHidden = true
            intructionsAttachedLabel.isHidden = assessmentDetails?.instructions?.isValid == true
                ? false
                : true
            showNextButton()
        }
    }

    func animatTransitionIfNeeded(state: AssessmentDetailOverViewState, duration: TimeInterval) {
        guard let parentView = parent?.view else { return }
        let parentHeight = parentView.bounds.height
        let safeAreaTop = parentView.safeAreaInsets.top
        
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                switch state {
                case .expanded:
                    self?.view.frame.origin.y = safeAreaTop
                    self?.hideNextButton()
                    self?.closeButton.isHidden = false
                    self?.viewAllLabel.isHidden = true
                    self?.intructionsAttachedLabel.isHidden = true
                case .collapsed:
                    self?.view.frame.origin.y = parentHeight - (self?.assessmentDetaildragViewHeight ?? 0) - 5
                }
            }
            frameAnimator.addCompletion { [weak self] _ in
                self?.assessmentDetailOverViewVisible.toggle()
                self?.runningAnimations.removeAll()
                self?.handledragViewExpansion(state: state)
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            handleCornerRadius(duration: duration, state: state)
            handleBlur(duration: duration, state: state)
        }
    }

    func startInteractiveTransition(state: AssessmentDetailOverViewState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animatTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }

    func hideNextButton() {
        nextButton.isHidden = true
    }

    func showNextButton() {
        if !isLastQuestionSelected, assessmentDetails?.questions?.count != 1 {
            nextButton.isHidden = false
        }
    }

    func questionMarkText(at index: Int) -> String {
        guard
            let totalMark = assessmentDetails?.questions?[index].mark,
            let studentMark = assessmentDetails?.questions?[index].studentMark
        else { return "" }

        let grade = Grade(currentMark: studentMark, totalMark: totalMark)
        return grade.description
    }
    
    func numberOfPointsText(of question: AssessmentQuestion) -> String {
        return question.localizedMarkText ?? ""
    }
    
    func getQuestionName(indexPath: IndexPath) -> String {
        let text = "\("quizzes.question".localiz()) \(indexPath.row + 1)"
        return Language.currentLanguage == .arabic ? text.enToArDigits : text
    }
}

// MARK: - IBActions
extension AssessmentDetailOverViewViewController {
    @IBAction private func submitButtonTapped(_ sender: UIButton) {
        submitButtonTapped?()
    }
}

// MARK: - Selectors
extension AssessmentDetailOverViewViewController {
     @objc private func handleDetailTap() {}
     
     @objc private func handleDetailPan(recognizer: UIPanGestureRecognizer) {
         switch recognizer.state {
         case .began:
             startInteractiveTransition(state: nextState, duration: 0.9)
         case .changed:
             let translation = recognizer.translation(in: detailOverView)
             var fractionComplete = translation.y / assessmentDetailOverViewHeight
             fractionComplete = assessmentDetailOverViewVisible ? fractionComplete : -fractionComplete
             updateInteractiveTransition(fractionCompleted: fractionComplete)
         case .ended:
             continueInternactiveTransition()
         default:
             break
         }
     }
}

// MARK: - UITableViewDataSource
extension AssessmentDetailOverViewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return assessmentDetails?.instructions?.isValid == true ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 where assessmentDetails?.instructions?.isValid == true:
            return 1
        default:
            return numberOfQuestions ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 where assessmentDetails?.instructions?.isValid == true:
            let cell: AssessmentDetailOverviewInstructionsTableViewCell = tableView.dequeueCell(for: indexPath)
            cell.configure(
                instructions: assessmentDetails?.instructions,
                module: module
            )
            return cell
        default:
            let cell: AssessmentDetailOverViewQuestionsTableViewCell = tableView.dequeueCell(for: indexPath)
            if let question = assessmentDetails?.questions?[indexPath.row] {
                return configureQuestionTableViewCell(at: indexPath, withCell: cell, withQuestion: question, tableView: questionsTableView)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension AssessmentDetailOverViewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is AssessmentDetailOverViewQuestionsTableViewCell {
            goToQuestion?(indexPath.row)
        }
    }
}
