// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Quizzes
  internal static var quizzes: String {
      return L10n.tr("Localizable", "quizzes")
    }

  internal enum Assignment {
    /// This answer is correct
    internal static var correctTitle: String {
        return L10n.tr("Localizable", "assignment.correctTitle")
      }
    /// This question isn't correct
    internal static var incorrectTitle: String {
        return L10n.tr("Localizable", "assignment.incorrectTitle")
      }
    /// Return
    internal static var pauseAlertCancelButtonTitle: String {
        return L10n.tr("Localizable", "assignment.pauseAlertCancelButtonTitle")
      }
    /// Make sure to come back and submit before due date
    internal static var pauseAlertMessage: String {
        return L10n.tr("Localizable", "assignment.pauseAlertMessage")
      }
    /// Pause exercise
    internal static var pauseAlertPauseButtonTitle: String {
        return L10n.tr("Localizable", "assignment.pauseAlertPauseButtonTitle")
      }
    /// Pause exercise for now
    internal static var pauseAlertTitle: String {
        return L10n.tr("Localizable", "assignment.pauseAlertTitle")
      }
  }

  internal enum Chat {
    /// Camera
    internal static var camera: String {
        return L10n.tr("Localizable", "chat.camera")
      }
    /// End chat
    internal static var endChat: String {
        return L10n.tr("Localizable", "chat.endChat")
      }
    /// Files
    internal static var files: String {
        return L10n.tr("Localizable", "chat.files")
      }
    /// Images
    internal static var images: String {
        return L10n.tr("Localizable", "chat.images")
      }
    /// Recording...
    internal static var recording: String {
        return L10n.tr("Localizable", "chat.recording")
      }
    /// Send
    internal static var send: String {
        return L10n.tr("Localizable", "chat.send")
      }
    /// Sending
    internal static var sending: String {
        return L10n.tr("Localizable", "chat.sending")
      }
  }

  internal enum CourseDetails {
    internal enum CancelBooking {
      /// Cancel Booking
      internal static var cancelButton: String {
          return L10n.tr("Localizable", "courseDetails.cancelBooking.cancelButton")
        }
      /// Are you sure you want to cancel booking of course?
      internal static var message: String {
          return L10n.tr("Localizable", "courseDetails.cancelBooking.message")
        }
      /// Message
      internal static var messageTitle: String {
          return L10n.tr("Localizable", "courseDetails.cancelBooking.messageTitle")
        }
      /// Return
      internal static var returnButton: String {
          return L10n.tr("Localizable", "courseDetails.cancelBooking.returnButton")
        }
    }
    internal enum CourseReview {
      /// by
      internal static var by: String {
          return L10n.tr("Localizable", "courseDetails.courseReview.by")
        }
      /// Describe Course...
      internal static var describeCourse: String {
          return L10n.tr("Localizable", "courseDetails.courseReview.describeCourse")
        }
      /// Message
      internal static var messageTitle: String {
          return L10n.tr("Localizable", "courseDetails.courseReview.messageTitle")
        }
      /// Would you like to rate content?
      internal static var rateContent: String {
          return L10n.tr("Localizable", "courseDetails.courseReview.rateContent")
        }
      /// Skip Rating
      internal static var skipRating: String {
          return L10n.tr("Localizable", "courseDetails.courseReview.skipRating")
        }
    }
    internal enum Main {
      /// Book Now
      internal static var bookNow: String {
          return L10n.tr("Localizable", "courseDetails.main.bookNow")
        }
      /// Cancel Booking
      internal static var cancelBooking: String {
          return L10n.tr("Localizable", "courseDetails.main.cancelBooking")
        }
      /// Details
      internal static var details: String {
          return L10n.tr("Localizable", "courseDetails.main.details")
        }
      /// Review Course
      internal static var reviewCourse: String {
          return L10n.tr("Localizable", "courseDetails.main.reviewCourse")
        }
      /// Reviews
      internal static var reviews: String {
          return L10n.tr("Localizable", "courseDetails.main.reviews")
        }
    }
    internal enum Receipt {
      /// Address
      internal static var address: String {
          return L10n.tr("Localizable", "courseDetails.receipt.address")
        }
      /// Course Name
      internal static var courseName: String {
          return L10n.tr("Localizable", "courseDetails.receipt.courseName")
        }
      /// Customer Name
      internal static var customerName: String {
          return L10n.tr("Localizable", "courseDetails.receipt.customerName")
        }
      /// Done
      internal static var done: String {
          return L10n.tr("Localizable", "courseDetails.receipt.done")
        }
      /// Receipt Number
      internal static var receiptNumber: String {
          return L10n.tr("Localizable", "courseDetails.receipt.receiptNumber")
        }
      /// Teacher Name
      internal static var teacherName: String {
          return L10n.tr("Localizable", "courseDetails.receipt.teacherName")
        }
    }
  }

  internal enum CreatePassword {
    /// All fields are required
    internal static var bothAreEmpty: String {
        return L10n.tr("Localizable", "createPassword.bothAreEmpty")
      }
    /// Confirm password
    internal static var confirmPassword: String {
        return L10n.tr("Localizable", "createPassword.confirmPassword")
      }
    /// Please make sure the password you entered is minimum 6 letters long
    internal static var passwordLengthTooShort: String {
        return L10n.tr("Localizable", "createPassword.passwordLengthTooShort")
      }
    /// The passwords you entered do not match
    internal static var passwordsDontMatch: String {
        return L10n.tr("Localizable", "createPassword.passwordsDontMatch")
      }
    /// Set new password
    internal static var setNewPassword: String {
        return L10n.tr("Localizable", "createPassword.setNewPassword")
      }
  }

  internal enum Home {
    /// Explore More
    internal static var exploreMore: String {
        return L10n.tr("Localizable", "home.exploreMore")
      }
    /// Help Center
    internal static var helpCenter: String {
        return L10n.tr("Localizable", "home.helpCenter")
      }
    /// Related Courses
    internal static var relatedCourses: String {
        return L10n.tr("Localizable", "home.relatedCourses")
      }
    /// View
    internal static var view: String {
        return L10n.tr("Localizable", "home.view")
      }
    internal enum Course {
      /// EGP
      internal static var price: String {
          return L10n.tr("Localizable", "home.course.price")
        }
      /// Return to teacher
      internal static var returnToTeacher: String {
          return L10n.tr("Localizable", "home.course.returnToTeacher")
        }
      /// See Receipt
      internal static var seeReceipt: String {
          return L10n.tr("Localizable", "home.course.seeReceipt")
        }
    }
  }

  internal enum Login {
    /// Please enter the mobile number and password
    internal static var bothAreEmpty: String {
        return L10n.tr("Localizable", "login.bothAreEmpty")
      }
    /// Forgot password?
    internal static var forgotPassword: String {
        return L10n.tr("Localizable", "login.forgotPassword")
      }
    /// Forgot password?\nNo worries!
    internal static var forgotPasswordTitle: String {
        return L10n.tr("Localizable", "login.forgotPasswordTitle")
      }
    /// Mobile number or password entered are not correct
    internal static var invalidCredentials: String {
        return L10n.tr("Localizable", "login.invalidCredentials")
      }
    /// Mobile number
    internal static var mobileNumber: String {
        return L10n.tr("Localizable", "login.mobileNumber")
      }
    /// Please enter the mobile number
    internal static var mobileNumberIsEmpty: String {
        return L10n.tr("Localizable", "login.mobileNumberIsEmpty")
      }
    /// No account? Sign up
    internal static var noAccount: String {
        return L10n.tr("Localizable", "login.noAccount")
      }
    /// Please enter your phone number, OTP will be sent to your mobile
    internal static var otpWillBeSent: String {
        return L10n.tr("Localizable", "login.otpWillBeSent")
      }
    /// Password
    internal static var password: String {
        return L10n.tr("Localizable", "login.password")
      }
    /// Please enter the password
    internal static var passwordIsEmpty: String {
        return L10n.tr("Localizable", "login.passwordIsEmpty")
      }
    /// Phone number
    internal static var phoneNumber: String {
        return L10n.tr("Localizable", "login.phoneNumber")
      }
    /// Send
    internal static var send: String {
        return L10n.tr("Localizable", "login.send")
      }
    /// Sign in
    internal static var signIn: String {
        return L10n.tr("Localizable", "login.signIn")
      }
    /// Welcome!\nSign in to continue
    internal static var welcome: String {
        return L10n.tr("Localizable", "login.welcome")
      }
  }

  internal enum Notifications {
    /// Notifications
    internal static var title: String {
        return L10n.tr("Localizable", "notifications.title")
      }
  }

  internal enum Profile {
    /// Academic type
    internal static var academicType: String {
        return L10n.tr("Localizable", "profile.academicType")
      }
    /// Address
    internal static var address: String {
        return L10n.tr("Localizable", "profile.address")
      }
    /// Batch/Year
    internal static var batch: String {
        return L10n.tr("Localizable", "profile.batch")
      }
    /// Change password
    internal static var changePassword: String {
        return L10n.tr("Localizable", "profile.changePassword")
      }
    /// City
    internal static var city: String {
        return L10n.tr("Localizable", "profile.city")
      }
    /// Country
    internal static var country: String {
        return L10n.tr("Localizable", "profile.country")
      }
    /// Division
    internal static var division: String {
        return L10n.tr("Localizable", "profile.division")
      }
    /// Your profile has been edited successfully
    internal static var editedSuccessfully: String {
        return L10n.tr("Localizable", "profile.editedSuccessfully")
      }
    /// Email
    internal static var email: String {
        return L10n.tr("Localizable", "profile.email")
      }
    /// Home phone number
    internal static var homePhone: String {
        return L10n.tr("Localizable", "profile.homePhone")
      }
    /// Logout
    internal static var logout: String {
        return L10n.tr("Localizable", "profile.logout")
      }
    /// Mobile number
    internal static var mobileNumber: String {
        return L10n.tr("Localizable", "profile.mobileNumber")
      }
    /// Another mobile number
    internal static var mobileNumber2: String {
        return L10n.tr("Localizable", "profile.mobileNumber2")
      }
    /// Name
    internal static var name: String {
        return L10n.tr("Localizable", "profile.name")
      }
    /// Parent phone number
    internal static var parentNumber: String {
        return L10n.tr("Localizable", "profile.parentNumber")
      }
    /// Parent second phone number
    internal static var parentNumber2: String {
        return L10n.tr("Localizable", "profile.parentNumber2")
      }
    /// Region
    internal static var region: String {
        return L10n.tr("Localizable", "profile.region")
      }
    /// Save
    internal static var save: String {
        return L10n.tr("Localizable", "profile.save")
      }
    /// Select Item
    internal static var selectItem: String {
        return L10n.tr("Localizable", "profile.selectItem")
      }
    /// specialization
    internal static var specialization: String {
        return L10n.tr("Localizable", "profile.specialization")
      }
  }

  internal enum Quizzes {
    /// 1 hr ago
    internal static var _1hour: String {
        return L10n.tr("Localizable", "quizzes.1hour")
      }
    /// 1 minute ago
    internal static var _1min: String {
        return L10n.tr("Localizable", "quizzes.1min")
      }
    /// 2 hrs
    internal static var _2hrs: String {
        return L10n.tr("Localizable", "quizzes.2hrs")
      }
    /// 2 minutes
    internal static var _2mins: String {
        return L10n.tr("Localizable", "quizzes.2mins")
      }
    /// If you are not ready please cancel and return back before the due date
    internal static var alertSubTitle: String {
        return L10n.tr("Localizable", "quizzes.alertSubTitle")
      }
    /// By starting the exam there is no turning back!
    internal static var alertTitle: String {
        return L10n.tr("Localizable", "quizzes.alertTitle")
      }
    /// Answered
    internal static var answered: String {
        return L10n.tr("Localizable", "quizzes.answered")
      }
    /// Open
    internal static var available: String {
        return L10n.tr("Localizable", "quizzes.available")
      }
    /// By
    internal static var by: String {
        return L10n.tr("Localizable", "quizzes.by")
      }
    /// Camera
    internal static var camera: String {
        return L10n.tr("Localizable", "quizzes.camera")
      }
    /// Choose %@ answers
    internal static func chooseMultipleAnswers(_ p1: Any) -> String {
      return L10n.tr("Localizable", "quizzes.chooseMultipleAnswers", String(describing: p1))
    }
    /// Choose 1 answer
    internal static var chooseOneAnswer: String {
        return L10n.tr("Localizable", "quizzes.chooseOneAnswer")
      }
    /// Choose one or more answers
    internal static var chooseOneOrMoreAnswers: String {
        return L10n.tr("Localizable", "quizzes.chooseOneOrMoreAnswers")
      }
    /// Choose %@ answers
    internal static func chooseThreeToTenAnswers(_ p1: Any) -> String {
      return L10n.tr("Localizable", "quizzes.chooseThreeToTenAnswers", String(describing: p1))
    }
    /// Choose 2 answers
    internal static var chooseTwoAnswers: String {
        return L10n.tr("Localizable", "quizzes.chooseTwoAnswers")
      }
    /// Closed
    internal static var closed: String {
        return L10n.tr("Localizable", "quizzes.closed")
      }
    /// Continue grading
    internal static var continueGrading: String {
        return L10n.tr("Localizable", "quizzes.continueGrading")
      }
    /// Due: 
    internal static var due: String {
        return L10n.tr("Localizable", "quizzes.due")
      }
    /// Duration:
    internal static var duration: String {
        return L10n.tr("Localizable", "quizzes.duration")
      }
    /// No Quizzes
    internal static var empty: String {
        return L10n.tr("Localizable", "quizzes.empty")
      }
    /// All submissions are checked
    internal static var emptyUnchecked: String {
        return L10n.tr("Localizable", "quizzes.emptyUnchecked")
      }
    /// end in %@ hours
    internal static func endIn2Hours(_ p1: Any) -> String {
      return L10n.tr("Localizable", "quizzes.endIn2Hours", String(describing: p1))
    }
    /// ends in %@ hours
    internal static func endInMoreThan10Hours(_ p1: Any) -> String {
      return L10n.tr("Localizable", "quizzes.endInMoreThan10Hours", String(describing: p1))
    }
    /// ends in %@ days
    internal static func endInMoreThan1Day(_ p1: Any) -> String {
      return L10n.tr("Localizable", "quizzes.endInMoreThan1Day", String(describing: p1))
    }
    /// ends in %@ hours
    internal static func endInMoreThan1HourAndLessThan11Hours(_ p1: Any) -> String {
      return L10n.tr("Localizable", "quizzes.endInMoreThan1HourAndLessThan11Hours", String(describing: p1))
    }
    /// ends in 1 day
    internal static var endInOneDay: String {
        return L10n.tr("Localizable", "quizzes.endInOneDay")
      }
    /// end in 1 hour
    internal static var endInOneHour: String {
        return L10n.tr("Localizable", "quizzes.endInOneHour")
      }
    /// ends in 1 week
    internal static var endInOneWeek: String {
        return L10n.tr("Localizable", "quizzes.endInOneWeek")
      }
    /// ends in %@
    internal static func endsIn(_ p1: Any) -> String {
      return L10n.tr("Localizable", "quizzes.endsIn", String(describing: p1))
    }
    /// a few seconds ago
    internal static var fewSeconds: String {
        return L10n.tr("Localizable", "quizzes.fewSeconds")
      }
    /// Files
    internal static var fileTitle: String {
        return L10n.tr("Localizable", "quizzes.fileTitle")
      }
    /// Finalized
    internal static var finalized: String {
        return L10n.tr("Localizable", "quizzes.finalized")
      }
    /// Finish
    internal static var finish: String {
        return L10n.tr("Localizable", "quizzes.finish")
      }
    /// Are you sure you want to submit?
    internal static var finishMessage: String {
        return L10n.tr("Localizable", "quizzes.finishMessage")
      }
    /// Gallery
    internal static var gallery: String {
        return L10n.tr("Localizable", "quizzes.gallery")
      }
    /// Go back anyway
    internal static var goBackAnyway: String {
        return L10n.tr("Localizable", "quizzes.goBackAnyway")
      }
    /// This grade will not be saved
    internal static var gradeWontSaved: String {
        return L10n.tr("Localizable", "quizzes.gradeWontSaved")
      }
    /// hour
    internal static var hour: String {
        return L10n.tr("Localizable", "quizzes.hour")
      }
    /// hrs
    internal static var hours: String {
        return L10n.tr("Localizable", "quizzes.hours")
      }
    /// Instructions:
    internal static var instructions: String {
        return L10n.tr("Localizable", "quizzes.instructions")
      }
    /// instructions attached
    internal static var instructionsAttached: String {
        return L10n.tr("Localizable", "quizzes.instructionsAttached")
      }
    /// Are you sure you want to mark this quiz as checked?
    internal static var markAsCheckedAlert: String {
        return L10n.tr("Localizable", "quizzes.markAsCheckedAlert")
      }
    /// minute
    internal static var minute: String {
        return L10n.tr("Localizable", "quizzes.minute")
      }
    /// minutes
    internal static var minutes: String {
        return L10n.tr("Localizable", "quizzes.minutes")
      }
    /// Next
    internal static var next: String {
        return L10n.tr("Localizable", "quizzes.next")
      }
    /// There is no quiz assigned yet
    internal static var noData: String {
        return L10n.tr("Localizable", "quizzes.noData")
      }
    /// Non-finalized
    internal static var nonFinialized: String {
        return L10n.tr("Localizable", "quizzes.nonFinialized")
      }
    /// There are questions not graded yet!. Please finish grading all questions.
    internal static var notAllGradedError: String {
        return L10n.tr("Localizable", "quizzes.notAllGradedError")
      }
    /// Not answered
    internal static var notAnswered: String {
        return L10n.tr("Localizable", "quizzes.notAnswered")
      }
    /// This grade is not final
    internal static var notFinalGrade: String {
        return L10n.tr("Localizable", "quizzes.notFinalGrade")
      }
    /// Not graded yet
    internal static var notGradedYet: String {
        return L10n.tr("Localizable", "quizzes.notGradedYet")
      }
    /// Not submitted
    internal static var notSubmitted: String {
        return L10n.tr("Localizable", "quizzes.notSubmitted")
      }
    /// %@ Questions
    internal static func numberOfQuestions(_ p1: Any) -> String {
      return L10n.tr("Localizable", "quizzes.numberOfQuestions", String(describing: p1))
    }
    /// Open
    internal static var `open`: String {
        return L10n.tr("Localizable", "quizzes.open")
      }
    /// Please enter grade
    internal static var pleaseEnterGrade: String {
        return L10n.tr("Localizable", "quizzes.pleaseEnterGrade")
      }
    /// point
    internal static var point: String {
        return L10n.tr("Localizable", "quizzes.point")
      }
    /// points
    internal static var points: String {
        return L10n.tr("Localizable", "quizzes.points")
      }
    /// Question
    internal static var question: String {
        return L10n.tr("Localizable", "quizzes.question")
      }
    /// Comment
    internal static var questionComment: String {
        return L10n.tr("Localizable", "quizzes.questionComment")
      }
    /// Questions
    internal static var questions: String {
        return L10n.tr("Localizable", "quizzes.questions")
      }
    /// Quiz grade
    internal static var quizGrade: String {
        return L10n.tr("Localizable", "quizzes.quizGrade")
      }
    /// Reviewed
    internal static var reviewed: String {
        return L10n.tr("Localizable", "quizzes.reviewed")
      }
    /// Save & Continue
    internal static var saveAndContinue: String {
        return L10n.tr("Localizable", "quizzes.saveAndContinue")
      }
    /// Show only unchecked submissions
    internal static var showOnlyUnchecked: String {
        return L10n.tr("Localizable", "quizzes.showOnlyUnchecked")
      }
    /// since
    internal static var since: String {
        return L10n.tr("Localizable", "quizzes.since")
      }
    /// Start
    internal static var start: String {
        return L10n.tr("Localizable", "quizzes.start")
      }
    /// Submit
    internal static var submitButtonTitle: String {
        return L10n.tr("Localizable", "quizzes.submitButtonTitle")
      }
    /// Submit
    internal static var submitButtonTitleForTeacherAlert: String {
        return L10n.tr("Localizable", "quizzes.submitButtonTitleForTeacherAlert")
      }
    /// Submitted
    internal static var submitted: String {
        return L10n.tr("Localizable", "quizzes.submitted")
      }
    /// Your answers will be submitted once you have a working internet connection
    internal static var submittedAlertConnectionMessage: String {
        return L10n.tr("Localizable", "quizzes.submittedAlertConnectionMessage")
      }
    /// Grades will be uploaded soon
    internal static var submittedAlertMessage: String {
        return L10n.tr("Localizable", "quizzes.submittedAlertMessage")
      }
    /// Thanks for you Submitting
    internal static var submittedAlertTitle: String {
        return L10n.tr("Localizable", "quizzes.submittedAlertTitle")
      }
    /// The answer
    internal static var theAnswer: String {
        return L10n.tr("Localizable", "quizzes.theAnswer")
      }
    /// This question's grade
    internal static var thisQuestionGrade: String {
        return L10n.tr("Localizable", "quizzes.thisQuestionGrade")
      }
    /// Questions
    internal static var threeToTenQuestions: String {
        return L10n.tr("Localizable", "quizzes.threeToTenQuestions")
      }
    /// Time duration
    internal static var timeDuration: String {
        return L10n.tr("Localizable", "quizzes.timeDuration")
      }
    /// Your answeres have been submitted
    internal static var timeOutDescription: String {
        return L10n.tr("Localizable", "quizzes.timeOutDescription")
      }
    /// We are sorry! time is out!
    internal static var timeOutTitle: String {
        return L10n.tr("Localizable", "quizzes.timeOutTitle")
      }
    /// Quizzes
    internal static var title: String {
        return L10n.tr("Localizable", "quizzes.title")
      }
    /// 2 points
    internal static var twoPoints: String {
        return L10n.tr("Localizable", "quizzes.twoPoints")
      }
    /// 2 Questions
    internal static var twoQuestions: String {
        return L10n.tr("Localizable", "quizzes.twoQuestions")
      }
    /// View all
    internal static var viewAll: String {
        return L10n.tr("Localizable", "quizzes.viewAll")
      }
    /// View description
    internal static var viewDescription: String {
        return L10n.tr("Localizable", "quizzes.viewDescription")
      }
    /// This grade will not be saved
    internal static var wontSaveGradeError: String {
        return L10n.tr("Localizable", "quizzes.wontSaveGradeError")
      }
    /// Write your answer
    internal static var writeAnswer: String {
        return L10n.tr("Localizable", "quizzes.writeAnswer")
      }
    /// Yesterday
    internal static var yesterday: String {
        return L10n.tr("Localizable", "quizzes.yesterday")
      }
    /// Your answer
    internal static var yourAnswer: String {
        return L10n.tr("Localizable", "quizzes.yourAnswer")
      }
    /// Your grade
    internal static var yourGrade: String {
        return L10n.tr("Localizable", "quizzes.yourGrade")
      }
  }

  internal enum Settings {
    /// Arabic
    internal static var arabic: String {
        return L10n.tr("Localizable", "settings.arabic")
      }
    /// Choose a language
    internal static var chooseALanguage: String {
        return L10n.tr("Localizable", "settings.chooseALanguage")
      }
    /// English
    internal static var english: String {
        return L10n.tr("Localizable", "settings.english")
      }
    /// Languages
    internal static var languages: String {
        return L10n.tr("Localizable", "settings.languages")
      }
    /// Notification
    internal static var notification: String {
        return L10n.tr("Localizable", "settings.notification")
      }
    /// Privacy policy
    internal static var privacyPolicy: String {
        return L10n.tr("Localizable", "settings.privacyPolicy")
      }
    /// Terms of service
    internal static var termsOfService: String {
        return L10n.tr("Localizable", "settings.termsOfService")
      }
    /// Version
    internal static var version: String {
        return L10n.tr("Localizable", "settings.version")
      }
  }

  internal enum Shared {
    internal enum Action {
      /// Cancel
      internal static var cancel: String {
          return L10n.tr("Localizable", "shared.action.cancel")
        }
    }
    internal enum Alerts {
      /// App will terminate.
      internal static var appWillTerminate: String {
          return L10n.tr("Localizable", "shared.alerts.appWillTerminate")
        }
      /// Error
      internal static var error: String {
          return L10n.tr("Localizable", "shared.alerts.error")
        }
      /// Screenshots Aren't Allowed!
      internal static var screenshotsNotAllowed: String {
          return L10n.tr("Localizable", "shared.alerts.screenshotsNotAllowed")
        }
      internal enum Camera {
        /// Wojood need to access camera
        internal static var message: String {
            return L10n.tr("Localizable", "shared.alerts.camera.message")
          }
        /// Camera Permission
        internal static var title: String {
            return L10n.tr("Localizable", "shared.alerts.camera.title")
          }
      }
      internal enum Microphone {
        /// Wojood need to access Microphone
        internal static var message: String {
            return L10n.tr("Localizable", "shared.alerts.microphone.message")
          }
      }
      internal enum Photos {
        /// Wojood need to access Photos
        internal static var message: String {
            return L10n.tr("Localizable", "shared.alerts.photos.message")
          }
        /// Gallery Permission
        internal static var title: String {
            return L10n.tr("Localizable", "shared.alerts.photos.title")
          }
      }
    }
  }

  internal enum Signup {
    internal enum AcademicInfo {
      /// SCHOOL
      internal static var school: String {
          return L10n.tr("Localizable", "signup.academicInfo.school")
        }
      /// UNIVERSITY
      internal static var university: String {
          return L10n.tr("Localizable", "signup.academicInfo.university")
        }
    }
    internal enum AddAvatar {
      /// Skip
      internal static var skip: String {
          return L10n.tr("Localizable", "signup.addAvatar.skip")
        }
      /// Submit
      internal static var submit: String {
          return L10n.tr("Localizable", "signup.addAvatar.submit")
        }
    }
    internal enum BasicInfo {
      /// Confirm password*
      internal static var confirmPassword: String {
          return L10n.tr("Localizable", "signup.basicInfo.confirmPassword")
        }
      /// Email*
      internal static var email: String {
          return L10n.tr("Localizable", "signup.basicInfo.email")
        }
      /// Home number
      internal static var homeNumber: String {
          return L10n.tr("Localizable", "signup.basicInfo.homeNumber")
        }
      /// * Cells with asterisks must be filled.
      internal static var mandatoryFieldsHint: String {
          return L10n.tr("Localizable", "signup.basicInfo.mandatoryFieldsHint")
        }
      /// Mobile number*
      internal static var mobileNumber: String {
          return L10n.tr("Localizable", "signup.basicInfo.mobileNumber")
        }
      /// Name*
      internal static var name: String {
          return L10n.tr("Localizable", "signup.basicInfo.name")
        }
      /// The mobile and/or email you've entered is already registered with another account
      internal static var numberAlreadyExistsError: String {
          return L10n.tr("Localizable", "signup.basicInfo.numberAlreadyExistsError")
        }
      /// Password*
      internal static var password: String {
          return L10n.tr("Localizable", "signup.basicInfo.password")
        }
      /// Mobile number must be linked to whatsapp.
      internal static var whatsappNumberHint: String {
          return L10n.tr("Localizable", "signup.basicInfo.whatsappNumberHint")
        }
    }
    internal enum LocationInfo {
      /// Address
      internal static var address: String {
          return L10n.tr("Localizable", "signup.locationInfo.address")
        }
      /// City*
      internal static var city: String {
          return L10n.tr("Localizable", "signup.locationInfo.city")
        }
      /// Country*
      internal static var country: String {
          return L10n.tr("Localizable", "signup.locationInfo.country")
        }
      /// District*
      internal static var district: String {
          return L10n.tr("Localizable", "signup.locationInfo.district")
        }
    }
    internal enum School {
      /// Academic Division*
      internal static var academicDivision: String {
          return L10n.tr("Localizable", "signup.school.academicDivision")
        }
      /// Academic Type*
      internal static var academicType: String {
          return L10n.tr("Localizable", "signup.school.academicType")
        }
      /// Academic Year*
      internal static var academicYear: String {
          return L10n.tr("Localizable", "signup.school.academicYear")
        }
      /// Parent Number*
      internal static var parentNumber: String {
          return L10n.tr("Localizable", "signup.school.parentNumber")
        }
      /// Parent Number 2
      internal static var parentNumber2: String {
          return L10n.tr("Localizable", "signup.school.parentNumber2")
        }
      /// School Name*
      internal static var schoolName: String {
          return L10n.tr("Localizable", "signup.school.schoolName")
        }
    }
    internal enum UniversityScreen {
      /// Field*
      internal static var field: String {
          return L10n.tr("Localizable", "signup.universityScreen.field")
        }
      /// Graduate
      internal static var graduate: String {
          return L10n.tr("Localizable", "signup.universityScreen.graduate")
        }
      /// Student
      internal static var student: String {
          return L10n.tr("Localizable", "signup.universityScreen.student")
        }
      /// University*
      internal static var university: String {
          return L10n.tr("Localizable", "signup.universityScreen.university")
        }
      /// Year*
      internal static var year: String {
          return L10n.tr("Localizable", "signup.universityScreen.year")
        }
    }
  }

  internal enum TabBar {
    /// Home
    internal static var home: String {
        return L10n.tr("Localizable", "tabBar.home")
      }
    /// My courses
    internal static var myCourses: String {
        return L10n.tr("Localizable", "tabBar.myCourses")
      }
    /// Settings
    internal static var settings: String {
        return L10n.tr("Localizable", "tabBar.settings")
      }
  }

  internal enum VerifyOtp {
    /// Continue
    internal static var `continue`: String {
        return L10n.tr("Localizable", "verifyOtp.continue")
      }
    /// Didn’t receive a code?
    internal static var didNotGetACode: String {
        return L10n.tr("Localizable", "verifyOtp.didNotGetACode")
      }
    /// If you didn’t receive a code please contact the admin
    internal static var didNotGetACodeAlert: String {
        return L10n.tr("Localizable", "verifyOtp.didNotGetACodeAlert")
      }
    /// Please enter the OTP sent to your phone
    internal static var pleaseEnterOTP: String {
        return L10n.tr("Localizable", "verifyOtp.pleaseEnterOTP")
      }
    /// Resend code
    internal static var resendCode: String {
        return L10n.tr("Localizable", "verifyOtp.resendCode")
      }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static var bundle: Bundle {
    Bundle(path: Bundle.main.path(forResource: Language.currentLanguage.rawValue, ofType: "lproj")!)!
  }
}
// swiftlint:enable convenience_type
