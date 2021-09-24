// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

class AssessmentDetailsViewModel {
    // MARK: - Private properties

    private let model = AssessmentDetailsModel()
    private var assessmentDetails: AssessmentDetails?
    var assissmentID: Int?

    // MARK: - Public properties

    var submittedStudentData: AssessmentSubmittedStudents?
    let status: AssessmentStatus
    let module: AssessmentsOverViewViewModel.Module
    var teacherLocalGrades = [TeacherLocalGradesForAssessment]()
    var isTeacherMadeAnyChange: Bool = false
    var assessmentTitle: String? {
        return assessmentDetails?.title
    }
    var totalDuration: Double? {
        return Double(assessmentDetails?.duration ?? 0)
    }
    var remainingDuration: Double? {
        return Double(assessmentDetails?.remainingDuration ?? 0)
    }
    var answeredQuestionsRatio: Float {
        let answeredQuestionsCount = assessmentDetails?.questions?
            .filter { $0.isAnswered == true }.count
        return Float(answeredQuestionsCount ?? 0) / Float(assessmentDetails?.questions?.count ?? 0)
    }
    var submittedAlertTitle: String {
        return module == .quizzes
            ? "quizzes.submittedAlertTitle".localiz()
            : "assignment.submittedAlertTitle".localiz()
    }
    var submittedAlertMessage: String {
        return module == .quizzes
            ? "quizzes.submittedAlertMessage".localiz()
            : "assignment.submittedAlertMessage".localiz()
    }

    var shouldShowFinishButton: Bool {
        return (status == .open)
    }

    // MARK: - Closures

    var updateAnsweredQuestions:(() -> Void)?
    var teacherUploadGradesSuccessHandler:((_: AssessmentSubmissionsResponse?) -> Void)?
    var invokeErrorHandler:((_ title: String, _ message: String) -> Void)?

    // MARK: - Initializers

    init(
        status: AssessmentStatus,
        module: AssessmentsOverViewViewModel.Module,
        assessmentID: Int?,
        assessmentDetails: AssessmentDetails?,
        submittedStudentData: AssessmentSubmittedStudents? = nil
    ) {
        self.status = status
        self.module = module
        self.assissmentID = assessmentID
        self.assessmentDetails = assessmentDetails
        self.submittedStudentData = submittedStudentData
    }

    // MARK: - Private functions

    private func getExcersiseStatusFor(question: AssessmentQuestion) -> AssessmentQuestion.AnswerState? {
        switch question.answerState {
        case .correct, .incorrect:
            return question.answerState
        default:
            return nil
        }
    }

    func getTeacherLocalGradesForQuestion(at index: Int) -> TeacherLocalGradesForAssessment? {
        return teacherLocalGrades.first { $0.indexPathRow == index }
    }

    func editTeacherLocalGradesWith(mark: Double? = nil, teacherComment: String? = nil, status: AssessmentQuestion.AnswerState? = nil, at index: Int) {
        if let mark = mark {
            getTeacherLocalGradesForQuestion(at: index)?.mark = mark
        }
        if let teacherComment = teacherComment {
            getTeacherLocalGradesForQuestion(at: index)?.teacherComment = teacherComment
        }
        if let status = status {
            getTeacherLocalGradesForQuestion(at: index)?.status = status
        }
        isTeacherMadeAnyChange = true
    }

    func isAllQuestionsGradedFromTeacher() -> Bool {
        let notGradesQuizes = teacherLocalGrades.filter { $0.mark == nil }
        let notGradesAssignments = teacherLocalGrades.filter { $0.status == nil }
        switch module {
        case .quizzes:
            return notGradesQuizes.isEmpty
        case .assignments:
            return notGradesAssignments.isEmpty
        default:
            return true
        }
    }

    private func generateTeacherGradeBody() -> TeacherSubmitGradeRequestModel {
        var grades: [GradeRequestModel] = []
        for question in teacherLocalGrades {
            var status = ""
            if module == .assignments {
                status = question.status?.rawValue ?? ""
            }
            let grade = GradeRequestModel(
                mark: question.mark ?? 0,
                comment: question.teacherComment ?? "",
                status: status,
                submissionID: question.submissionID ?? 0
            )
            grades.append(grade)
        }
        return TeacherSubmitGradeRequestModel(grades: grades)
    }

    private func submitAnswerWithoutAttachment(questionID: Int) {
        guard
            let assessmentID = assissmentID,
            let question = assessmentDetails?.questions?.first(where: { $0.id == questionID }),
            let parameters = question.getSubmittedAnswerParameters(ignoreAttachment: true)
        else { return }

        model.submitAnswer(assessmentID: assessmentID, parameters: parameters, module: module.rawValue) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            } else {
                question.deleteAnswerManagedObject()
            }
        }
    }

    private func deleteAnswerAttachment(questionID: Int?) {
        guard let assessmentID = assissmentID,
            let question = assessmentDetails?.questions?.first(where: { $0.id == questionID }),
            let parameters = question.getSubmittedAnswerParameters(ignoreAttachment: false)
            else { return }
        model.submitAnswer(assessmentID: assessmentID, parameters: parameters, module: module.rawValue) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }

    private func submitAnswerWithAttachment(
        with url: URL?,
        questionID: Int,
        freeTextAnswer: String?,
        progressCompletion: @escaping (Double) -> Void,
        completion: @escaping (AssessmentQuestion?, Error?) -> Void
    ) {
        guard
            let assessmentID = assissmentID,
            let mimeType = url?.mimeType,
            let fileName = url?.lastPathComponent,
            let question = assessmentDetails?.questions?.first(where: { $0.id == questionID }),
            let parameters = question.getFreeTextParameters(questionID, freeTextAnswer, ignoreAttachment: false, ignoreFreeTextAnswer: true)
        else { return }

        model.uploadDocumentAnswer(
            assessmentID: assessmentID,
            questionID: questionID,
            fileURL: url,
            fileName: fileName,
            mimeType: mimeType,
            parameters: parameters,
            module: module.rawValue,
            progressCompletion: progressCompletion
        ) { [weak self] question, error in
            if error == nil {
                let question = self?.assessmentDetails?.questions?.first { $0.id == questionID }
                question?.deleteAnswerManagedObject()
            }
            completion(question, error)
        }
    }

    private func submitAnswer(
        for questionID: Int?,
        progressCompletion: ((Double) -> Void)? = nil
    ) {
        let matchedQuestion = assessmentDetails?.questions?.first { $0.id == questionID }
        guard let question = matchedQuestion,
            let questionID = question.id else { return }
        switch question.type {
        case .mcq, .trueOrFalse, .freeText:
            submitAnswerWithoutAttachment(questionID: questionID)
        default:
            return
        }
    }

    // MARK: - Public functions

    func getAssessmentDetails() -> AssessmentDetails? {
        return assessmentDetails
    }

    func numberOfQustions() -> Int? {
        return assessmentDetails?.questions?.count
    }

    func getQuestion(at index: Int) -> AssessmentQuestion? {
        guard assessmentDetails?.questions?.indices.contains(index) == true
            else { return nil }
        return assessmentDetails?.questions?[index]
    }

    func setStatusForQuestion(at index: Int, status: AssessmentQuestion.AnswerState) {
        guard assessmentDetails?.questions?.indices.contains(index) == true
            else { return }
        assessmentDetails?.questions?[index].answerState = status
    }

    func cancelUploadRequest(_ questionID: Int?) {
        model.cancelUploadRequest(for: questionID)
    }

    func addAttachment(
        _ url: URL,
        _ questionID: Int?
    ) {
        guard let questionID = questionID else { return }
        let question = assessmentDetails?.questions?.first { $0.id == questionID }
        question?.submittedAttachment = url.absoluteString
        submitAnswerWithAttachment(
            with: url,
            questionID: questionID,
            freeTextAnswer: question?.submittedFreeTextAnswer,
            progressCompletion: { progress in
                print(progress)
        }, completion: { _, _ in }
        )
    }

    func deleteAttachment(_ questionID: Int?) {
        assessmentDetails?.questions?.first { $0.id == questionID }?.submittedAttachment = nil
        deleteAnswerAttachment(questionID: questionID)
    }

    private func handleError(_ error: Error?) {
        guard let error = error else { return }

        let alertData = ErrorParser.retrieveAlertData(fromError: error as NSError?)
        if !alertData.shouldDiscard {
            invokeErrorHandler?(alertData.title, alertData.message)
        }
    }

    func submitQuestionAnswer(at index: Int) {
        let questionID = assessmentDetails?.questions?[index].id
        submitAnswer(for: questionID)
    }

    func finishAssessment(_ completion: ((Error?) -> Void)? = nil) {
        guard let assissmentID = assissmentID else { return }
        model.finishAssessment(assessmentID: assissmentID, module: module.rawValue) { error in
            if error != nil {
                completion?(error)
            } else {
                completion?(nil)
            }
        }
    }

    func downloadAttachemt(
        with url: URL,
        delegate: URLSessionDownloadDelegate
    ) {
        model.downloadAttachment(with: url, delegate: delegate)
    }

    func getNumberOfAnsweredQuestionsText() -> String? {
        guard let totalQuestionsNumber = assessmentDetails?.questions?.count else { return nil }
        let answeredQuestionsCount = assessmentDetails?.questions?
            .filter { $0.isAnswered == true }.count
        let answeredQuestionsNumberText = NumberFormatter.getFormattedString(fromInt: answeredQuestionsCount ?? 0) ?? ""
        let totalQuestionsNumberText = String(format: "quizzes.numberOfQuestions".localiz(), NumberFormatter.getFormattedString(fromInt: Int(totalQuestionsNumber)) ?? "")
        return Language.currentLanguage == .arabic
            ? answeredQuestionsNumberText + " \\ " + totalQuestionsNumberText
            : answeredQuestionsNumberText + " / " + totalQuestionsNumberText
    }

    func isLastQuestion(at index: Int) -> Bool {
        guard let questionsCount = assessmentDetails?.questions?.count else { return false }
        return index == questionsCount - 1
    }

    func isQuestionAnswered(at index: Int) -> Bool {
        return assessmentDetails?.questions?[index].isAnswered ?? false
    }

    func isWrongAnswer(at index: Int) -> Bool {
        if assessmentDetails?.questions?[index].studentMark == 0
            || assessmentDetails?.questions?[index].comment?.isValid == true {
            return true
        }
        return false
    }

    func isRightAnswer(at index: Int) -> Bool {
        return (assessmentDetails?.questions?[index].studentMark ?? 0.0) > 0.0
    }

    func questionState(at index: Int) -> AssessmentQuestion.AnswerState {
        return assessmentDetails?.questions?[index].answerState ?? .notReviewed
    }

    func questionMarkText(at index: Int) -> String {
        guard
            let totalMark = assessmentDetails?.questions?[index].mark,
            let studentMark = assessmentDetails?.questions?[index].studentMark
        else {
            return "quizzes.notGradedYet".localiz()
        }

        let grade = Grade(currentMark: studentMark, totalMark: totalMark)
        return grade.description
    }

    func getCounterString(minutes: Int, seconds: Int) -> String? {
        var minutesString = NumberFormatter.getFormattedString(fromInt: minutes) ?? "00"
        if minutes < 10 {
            minutesString = "\(NumberFormatter.getFormattedString(fromInt: 0) ?? "0")\(minutesString)"
        }

        var secondsString = NumberFormatter.getFormattedString(fromInt: seconds) ?? "00"
        if seconds < 10 {
            secondsString = "\(NumberFormatter.getFormattedString(fromInt: 0) ?? "0")\(secondsString)"
        }

        return "\(minutesString):\(secondsString)"
    }

    func getUpdatedRemainingTimeInSeconds() -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = GlobalConstants.dateTimeFormat
        guard let startedAt = assessmentDetails?.startedAt,
            let availableTo = assessmentDetails?.availableTo,
            let totalDurationInSeconds = assessmentDetails?.duration,
            let startedAtDate = formatter.date(from: startedAt),
            let availableToDate = formatter.date(from: availableTo)
            else { return nil }
        let durationSinceStudentStarted = Date().timeIntervalSince(startedAtDate)
        let remainingTimeSinceStartTime = Double(totalDurationInSeconds) - durationSinceStudentStarted
        var remainingTime = 0
        if Date().addingTimeInterval(remainingTimeSinceStartTime) >= availableToDate {
            remainingTime = Int(availableToDate.timeIntervalSince(Date()))
        } else {
            remainingTime = Int(remainingTimeSinceStartTime)
        }
        return remainingTime <= 0 ? 0 : remainingTime
    }

    func setAttachedFileLocalURL(url: URL, questionID: Int?) {
        let question = assessmentDetails?.questions?.first { $0.id == questionID }
        question?.submittedAttachment = url.absoluteString
    }

    func saveAnswersManagedObjects() {
        try? LocalSettingsConfiguratorAppDelegate.shared.persistentContainer.viewContext.save()
    }

    func updateQuestionAnsweredStatus(_ questionID: Int?) {
        let question = assessmentDetails?.questions?.first { $0.id == questionID }
        guard let answeredQuestion = question else {
            question?.isAnswered = false
            return
        }
        switch answeredQuestion.type {
        case .mcq where !answeredQuestion.selectedChoices.isEmpty,
             .trueOrFalse where !answeredQuestion.selectedChoices.isEmpty :
            question?.isAnswered = true
        case .freeText where (answeredQuestion.submittedAttachment?.isValid == true
            || answeredQuestion.submittedFreeTextAnswer?.isValid == true):
            question?.isAnswered = true
        default:
            question?.isAnswered = false
        }
        updateAnsweredQuestions?()
    }
}
