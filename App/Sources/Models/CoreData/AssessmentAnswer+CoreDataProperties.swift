// Copyright © 2021 Pharos Solutions. All rights reserved.
//

import Foundation
import CoreData


extension AssessmentAnswer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssessmentAnswer> {
        return NSFetchRequest<AssessmentAnswer>(entityName: "AssessmentAnswer")
    }

    @NSManaged public var assessmentId: Int32
    @NSManaged public var attachmentURL: String?
    @NSManaged public var choices: NSObject?
    @NSManaged public var freeText: String?
    @NSManaged public var isFreeText: Bool
    @NSManaged public var module: String?
    @NSManaged public var questionId: Int32
    @NSManaged public var studentId: Int32

}
