# Assessments Architecture & Data Flow - Technical Baseline

**Document Date:** May 5, 2026  
**Project:** Wojod-iOS  
**Purpose:** Complete architectural mapping of the Assessments module

---

## 1. OVERVIEW

The Assessments module handles both **Quizzes** and **Assignments** for students. It supports:
- Starting assessments
- Answering questions (MCQ, True/False, Free Text with attachments)
- Submitting individual answers
- Finishing/closing assessments
- Viewing results (for closed assessments)
- Offline answer synchronization

---

## 2. ENDPOINTS, HTTP METHODS & ROUTE DEFINITIONS

### 2.1 Base URL Structure
```
Base URL: {AppEnvironment.rootURL}/{module}/{assessment_id}/{action}
```

**Module values:**
- `quizzes` - for quiz assessments
- `assignments` - for assignment assessments

### 2.2 Complete Endpoint Catalog

| Action | HTTP Method | Route | Purpose |
|--------|-------------|-------|---------|
| **Start Assessment** | POST | `/{module}/{assessment_id}/start` | Begin an assessment session |
| **Get Assessment Details** | GET | `/{module}/{assessment_id}` | Fetch assessment questions |
| **Get Assessment Results** | GET | `/{module}/{assessment_id}/results` | Fetch completed assessment results |
| **Submit One Answer** | POST | `/{module}/{assessment_id}/submit_one_answer` | Submit individual question answer |
| **Finish Assessment** | POST | `/{module}/{assessment_id}/finish` | Close/finalize the assessment |
| **Get Submissions List** | GET | `/{module}/{assessment_id}/student_submission_details` | Get submission details |
| **Download Attachment** | GET | `{full_attachment_url}` | Download question/answer attachments |

### 2.3 Implementation Files

**Primary API Client:** `/App/Sources/Networking/Assessments/APIClient.swift`
- Singleton: `APIClient.shared`
- Uses `AssessmentDetailsAPIClient` internally

**Secondary API Clients:**
- `/App/Sources/Networking/Assessments/AssessmentsAPIClient.swift` - List fetching
- `/App/Sources/Networking/Assessments/AssessmentDetailsAPIClient.swift` - Detail operations

---

## 3. REQUEST/RESPONSE STRUCTURES

### 3.1 START ASSESSMENT

**Request:**
```http
POST /{module}/{assessment_id}/start
Headers: [access-token, uid, client]
Parameters (query string):
  - device_token: String (UUID from UIDevice.identifierForVendor)
```

**Response (AssessmentDetails):**
```json
{
  "id": 123,
  "title": "Quiz Title",
  "instructions": "Follow instructions...",
  "available_to": "2026-05-10 23:59:59",
  "started_at": "2026-05-05 10:00:00",
  "finished_at": null,
  "mark": 100.0,
  "student_total_mark": null,
  "duration": 3600,
  "remaining_duration": 3600,
  "grade_final": false,
  "questions": [
    {
      "id": 1,
      "title": "Question text?",
      "question_type": "mcq|true_false|free_text",
      "mark": 10.0,
      "student_mark": null,
      "position": 1,
      "difficulty": "easy|medium|hard",
      "attachment": "/path/to/image.jpg",
      "attachment_type": "image/jpeg",
      "model_answer": "Correct answer explanation",
      "maximum_allowed_choices": 1,
      "is_single_choice": true,
      "choices": [
        {
          "id": 1,
          "title": "Option A",
          "model_answer": true,
          "attachment": null,
          "attachment_type": null
        }
      ]
    }
  ]
}
```

### 3.2 SUBMIT ONE ANSWER (MCQ/TrueFalse)

**Request:**
```http
POST /{module}/{assessment_id}/submit_one_answer
Headers: [access-token, uid, client, Content-Type: application/json]
Body (JSON):
{
  "device_token": "UUID-string",
  "question_id": 1,
  "choices_ids": [1, 2],
  "free_text_answer": null,
  "ignore_attachment": "true"
}
```

**Response:** HTTP 200 on success

### 3.3 SUBMIT ONE ANSWER (Free Text with Attachment)

**Request:**
```http
POST /{module}/{assessment_id}/submit_one_answer
Headers: [access-token, uid, client, Content-Type: multipart/form-data]
Multipart Form Data:
  - attachment: File (optional)
  - device_token: String
  - question_id: Int
  - free_text_answer: String
  - ignore_attachment: "false"
  - ignore_free_text_answer: "false"
```

**Response (AnsweredQuestion):**
```json
{
  "question": {
    "id": 1,
    "submitted_attachment": "/path/to/uploaded/file.jpg",
    "submitted_attachment_type": "image/jpeg",
    "submitted_file_name": "file.jpg"
  }
}
```

### 3.4 FINISH ASSESSMENT

**Request:**
```http
POST /{module}/{assessment_id}/finish
Headers: [access-token, uid, client]
Parameters (query string - URLEncoded):
  - device_token: String (UUID)
```

**Response:** HTTP 200 on success

### 3.5 GET ASSESSMENT RESULTS

**Request:**
```http
GET /{module}/{assessment_id}/results
Headers: [access-token, uid, client]
Query Params (optional):
  - student_id: Int (for parent/teacher viewing)
```

**Response:** Same as AssessmentDetails with `student_mark` and `answer_state` populated

---

## 4. ENCODING, DECODING & SERIALIZATION

### 4.1 JSON Decoding Strategy

**Date Format:**
```swift
let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // GlobalConstants.dateTimeFormat
```

**Key Mapping (snake_case → camelCase):**
```swift
// AssessmentDetails.swift
private enum CodingKeys: String, CodingKey {
    case startedAt = "started_at"
    case finishedAt = "finished_at"
    case availableTo = "available_to"
    case studentTotalMark = "student_total_mark"
    case remainingDuration = "remaining_duration"
    case isGradeFinal = "grade_final"
}

// AssessmentQuestion.swift
private enum CodingKeys: String, CodingKey {
    case modelAnswer = "model_answer"
    case studentMark = "student_mark"
    case questionType = "question_type"
    case questionAttachment = "attachment"
    case attachmentType = "attachment_type"
    case submittedFileName = "submitted_file_name"
    case submittedAttachment = "submitted_attachment"
    case submittedAttachmentType = "submitted_attachment_type"
    case maximumAllowedChoices = "maximum_allowed_choices"
    case submittedFreeTextAnswer = "submitted_free_text_answer"
    case questioAnswerState = "answer_state"
    case submissionId = "submission_id"
    case isSingleChoice = "is_single_choice"
    case correctionImages = "correction_images"
}
```

### 4.2 Parameter Encoding Variations

| Endpoint | Encoding Type | Content-Type |
|----------|--------------|--------------|
| Start Assessment | `URLEncoding(destination: .queryString)` | Form |
| Submit Answer (no attachment) | `JSONEncoding.default` | JSON |
| Submit Answer (with attachment) | `MultipartFormData` | multipart/form-data |
| Finish Assessment | `URLEncoding.default` | Form |
| Get Details/Results | `URLEncoding.default` | Query params |

### 4.3 Core Data Persistence (Offline Support)

**Entity:** `AssessmentAnswer` (NSManagedObject)

**Properties:**
```swift
@NSManaged public var assessmentId: Int32
@NSManaged public var attachmentURL: String?
@NSManaged public var choices: NSObject?  // [Int32] array
@NSManaged public var freeText: String?
@NSManaged public var isFreeText: Bool
@NSManaged public var module: String?
@NSManaged public var questionId: Int32
@NSManaged public var studentId: Int32
```

---

## 5. DATA FLOW: ROUTE → CONTROLLER → SERVICE → DATABASE

### 5.1 High-Level Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        VIEW CONTROLLER LAYER                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────────────┐      ┌─────────────────────────────────┐ │
│  │ AssessmentsOverView │      │ AssessmentDetailsViewController │ │
│  │  ViewController     │      │                                 │ │
│  └─────────┬───────────┘      └───────────────┬─────────────────┘ │
│            │                                    │                   │
│            │  selection                         │  answer/finish    │
│            ▼                                    ▼                   │
│  ┌─────────────────────┐      ┌─────────────────────────────────┐ │
│  │ AssessmentsOverView │      │ AssessmentQuestionViewController│ │
│  │    ViewModel        │      │                                 │ │
│  └─────────┬───────────┘      └─────────────────────────────────┘ │
│            │                                    │                   │
└────────────┼────────────────────────────────────┼───────────────────┘
             │                                    │
             ▼                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         BUSINESS LOGIC LAYER                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────────────┐      ┌─────────────────────────────────┐ │
│  │ AssessmentsOverView │      │   AssessmentDetailsViewModel      │ │
│  │     ViewModel       │      │                                 │ │
│  └─────────┬───────────┘      └───────────────┬─────────────────┘ │
│            │                                    │                   │
│            │                                    │                   │
│            ▼                                    ▼                   │
│  ┌─────────────────────┐      ┌─────────────────────────────────┐ │
│  │ AssessmentsOverView │      │      AssessmentDetailsModel       │ │
│  │       Model         │      │                                 │ │
│  └─────────┬───────────┘      └───────────────┬─────────────────┘ │
│            │                                    │                   │
└────────────┼────────────────────────────────────┼───────────────────┘
             │                                    │
             ▼                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         NETWORKING LAYER                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    APIClient.shared                          │   │
│  │  (Singleton - delegates to specific API clients)             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│         ┌────────────────────┼────────────────────┐                  │
│         ▼                    ▼                    ▼                  │
│  ┌──────────────┐  ┌─────────────────┐  ┌─────────────────────┐    │
│  │AssessmentsAPI│  │AssessmentDetails│  │ AssessmentDetails   │    │
│  │   Client     │  │   APIClient     │  │   APIClient         │    │
│  └──────────────┘  └─────────────────┘  └─────────────────────┘    │
│         │                  │                    │                    │
│         ▼                  ▼                    ▼                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Alamofire Session                         │   │
│  │         (ApiManager.manager - Session singleton)             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
└──────────────────────────────┼──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        PERSISTENCE LAYER                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────────────────┐  ┌─────────────────────────────────┐ │
│  │   Core Data (SQLite)      │  │         File System             │ │
│  │  AssessmentAnswer Entity  │  │   (Attachment Downloads)        │ │
│  └─────────────────────────┘  └─────────────────────────────────┘ │
│                                                                    │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 Starting an Assessment - Detailed Flow

```
1. User taps assessment in list
   └─▶ AssessmentsOverViewViewController
       └─▶ startAssessment(with:completion:)
           ├─▶ AssessmentDetailsModel().startAssessment()
           │   └─▶ APIClient.shared.startAssessment()
           │       └─▶ AssessmentDetailsAPIClient.startAssessment()
           │           ├─▶ URL: /{module}/{id}/start
           │           ├─▶ Method: POST
           │           ├─▶ Parameters: ["device_token": UUID]
           │           └─▶ Alamofire.request(...)
           │               └─▶ Response: AssessmentDetails JSON
           └─▶ Decode JSON → AssessmentDetails model
               └─▶ Navigate to AssessmentDetailsViewController
```

### 5.3 Submitting an Answer - Detailed Flow

```
1. User selects answer option
   └─▶ AssessmentQuestionViewController
       └─▶ didSelectOption(at:)
           └─▶ AssessmentQuestionViewModel.didSelectOption()
               └─▶ Update AssessmentQuestion.selectedChoices
                   ├─▶ Save to CoreData (AssessmentAnswer entity)
                   └─▶ Trigger delegate.didAnswerQuestion()
                       └─▶ AssessmentDetailsViewController
                           └─▶ submitQuestionAnswer(at:)
                               └─▶ AssessmentDetailsViewModel.submitQuestionAnswer()
                                   └─▶ AssessmentDetailsModel.submitAnswer()
                                       └─▶ APIClient.shared.submitAssessmentAnswer()
                                           ├─▶ URL: /{module}/{id}/submit_one_answer
                                           ├─▶ Method: POST
                                           ├─▶ Body: {
                                           │     device_token: UUID
                                           │     question_id: Int
                                           │     choices_ids: [Int]
                                           │     free_text_answer: String?
                                           │     ignore_attachment: "true"
                                           │   }
                                           └─▶ On success: Delete CoreData entry
```

### 5.4 Closing/Finishing an Assessment - Detailed Flow

```
1. User taps "Finish" button or timer expires
   └─▶ AssessmentDetailsViewController
       └─▶ finishAssessmentAssignmentForParentAndStudent()
           └─▶ assessmentFinishedForParentAndStudent()
               └─▶ Show confirmation alert
                   └─▶ User confirms
                       └─▶ handleEndingAssessment()
                           ├─▶ submitQuestionAnswer(at:) // Submit current answer
                           ├─▶ AssessmentSynchronization.startSynchronizationForQuiz()
                           │   ├─▶ Fetch all pending answers from CoreData
                           │   ├─▶ Send each answer sequentially via sendRequest()
                           │   └─▶ On completion: Call synchronizationCompletionHandler
                           └─▶ viewModel?.finishAssessment()
                               └─▶ AssessmentDetailsModel.finishAssessment()
                                   └─▶ APIClient.shared.finishAssessment()
                                       ├─▶ URL: /{module}/{id}/finish
                                       ├─▶ Method: POST
                                       ├─▶ Parameters: ["device_token": UUID]
                                       └─▶ Response: HTTP 200
                                           └─▶ Show success alert
                                               └─▶ Pop to previous screen
```

---

## 6. STATE MANAGEMENT & VALIDATIONS FOR CLOSING ASSESSMENT

### 6.1 Prerequisites for Closing

| Validation | Location | Purpose |
|------------|----------|---------|
| Network connectivity check | `handleEndingAssessment()` | Decide sync vs offline path |
| Answers synchronization | `AssessmentSynchronization` | Ensure all answers sent |
| Timer status | `AssessmentDetailsViewController` | Handle timeout scenarios |

### 6.2 State Tracking

```swift
// AssessmentDetailsViewModel
var status: AssessmentStatus  // .open or .closed
var shouldShowFinishButton: Bool { return status == .open }

// Answer tracking
var answeredQuestionsRatio: Float {
    let answeredCount = assessmentDetails?.questions?.filter { $0.isAnswered }.count
    return Float(answeredCount) / Float(totalQuestions)
}
```

### 6.3 Offline Mode Handling

```swift
// When network is unavailable during finish:
func handleFininshAssessmentInOfflineMode() {
    // 1. Show partial success message
    // 2. Save current answer to CoreData
    // 3. Call finishAssessment() (queues locally)
    // 4. Pop navigation
}
```

### 6.4 Synchronization Sequence

```swift
class AssessmentSynchronization {
    func startSynchronizationForQuiz(id: Int) {
        // 1. Fetch all AssessmentAnswer objects from CoreData
        // 2. Filter by current quiz ID
        // 3. Process LIFO (last in, first out):
        //    - Get last answer
        //    - Determine if attachment exists
        //    - Call submitAnswerWithoutAttachment() OR uploadAttachement()
        //    - On success: Delete CoreData entry, move to next
        //    - On failure: Stop sync, keep for retry
        // 4. Call synchronizationCompletionHandler when empty
    }
}
```

---

## 7. KEY MODELS & DATA STRUCTURES

### 7.1 AssessmentStatus
```swift
enum AssessmentStatus: String, CaseIterable {
    case open    // Currently active/takable
    case closed  // Completed/expired
}
```

### 7.2 QuestionType
```swift
enum QuestionType: String {
    case mcq         // Multiple choice
    case trueOrFalse = "true_false"
    case freeText    = "free_text"
    case none = ""
}
```

### 7.3 AnswerState (for closed assessments)
```swift
enum AnswerState: String {
    case correct
    case incorrect
    case notReviewed = "not_reviewed"
    case needsImprovement = "needs_improvement"
}
```

### 7.4 Module Enum
```swift
enum Module: String, CaseIterable {
    case all        // Combined list
    case quizzes    // Quiz type only
    case assignments // Assignment type only
}
```

---

## 8. FILE STRUCTURE REFERENCE

```
/App/Sources/
├── Models/
│   ├── Assessment/
│   │   ├── Assessment.swift                     # Basic assessment info
│   │   ├── AssessmentChoice.swift               # MCQ option
│   │   ├── AssessmentDetails.swift            # Full assessment with questions
│   │   ├── AssessmentQuestion.swift           # Individual question
│   │   ├── AssessmentStatus.swift               # Status enum
│   │   ├── AssessmentType.swift                 # Quiz vs Assignment
│   │   ├── AssessmentsResponse.swift            # API response wrapper
│   │   ├── AssessmentSubmissionRequestModel.swift
│   │   ├── AssessmentSubmissionDetailsRequestModel.swift
│   │   ├── AssessmentSubmissions.swift          # Submission list response
│   │   └── TeacherGradesForAssessment.swift
│   └── CoreData/
│       ├── AssessmentAnswer+CoreDataClass.swift
│       └── AssessmentAnswer+CoreDataProperties.swift
├── Networking/
│   └── Assessments/
│       ├── APIClient.swift                      # Main facade
│       ├── AssessmentDetailsAPIClient.swift   # Detail operations
│       ├── AssessmentsAPIClient.swift           # List operations
│       ├── AssessmentSynchronization.swift    # Offline sync
│       └── ...
└── ScreenFlows/
    └── Assessments/
        ├── AssessmentsOverViewViewModel.swift    # List VM
        ├── AssessmentsOverViewModel.swift       # List Model
        ├── AssessmentDetails/
        │   ├── AssessmentDetailsConfigurator.swift  # DI setup
        │   ├── AssessmentDetailsModel.swift      # Detail Model
        │   ├── AssessmentDetailsViewController.swift
        │   ├── AssessmentDetailsViewModel.swift  # Detail VM
        │   └── Views/
        ├── AssessmentDetailOverVIew/
        │   └── AssessmentDetailOverViewViewController.swift
        └── AssessmentQuestion/
            ├── AssessmentQuestionViewController.swift
            └── AssessmentQuestionViewModel.swift
```

---

## 9. CRITICAL IMPLEMENTATION NOTES

### 9.1 Device Token
- Used for session tracking across start/submit/finish
- Source: `UIDevice.current.identifierForVendor?.uuidString`
- Passed in all assessment operations

### 9.2 Core Data Lifecycle
1. When user answers: Create `AssessmentAnswer` entity
2. After successful API submit: Delete entity
3. If API fails: Entity remains for retry
4. Synchronization processes all pending entities LIFO

### 9.3 Timer Handling
```swift
// Timer updates every 1 second
// Saves CoreData every 10 seconds (when counter % 10 == 0)
// Turns UI red when < 10% time remaining
```

### 9.4 Attachment Handling
1. File saved to app Documents directory
2. File path stored in `AssessmentAnswer.attachmentURL`
3. Upload via multipart form
4. Server returns URL - stored in `submittedAttachment`

---

**END OF BASELINE DOCUMENT**
