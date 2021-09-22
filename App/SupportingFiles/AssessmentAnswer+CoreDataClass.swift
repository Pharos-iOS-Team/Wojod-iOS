// Copyright © 2021 Pharos Solutions. All rights reserved.
// swiftlint:disable all

import Foundation
import CoreData
import UIKit

@objc(AssessmentAnswer)
public class AssessmentAnswer: NSManagedObject {
    // MARK: - Private functions

    private func getContext() -> NSManagedObjectContext? {
        return LocalSettingsConfiguratorAppDelegate.shared.persistentContainer.viewContext
    }
    
    private func delete(withPredicate predicate: NSPredicate? = nil, completion: @escaping ([NSManagedObject]) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "\(AssessmentAnswer.self)")
        fetchRequest.predicate = predicate
        let managedContext = getContext()
        let result = try? managedContext?.fetch(fetchRequest)
        if let resultData = result as? [AssessmentAnswer] {
            for answer in resultData {
                managedContext?.delete(answer)
            }
        }
    }
    
    private func deleteAll(completion: @escaping ([NSManagedObject]) -> Void) {
        let managedContext = getContext()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "\(AssessmentAnswer.self)")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        guard let context = managedContext, let persistentStoreCoordinator =  managedContext?.persistentStoreCoordinator else {
            return
        }
        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let error as NSError {
            print(error)
        }
    }

    private func fetch(withPredicate predicate: NSPredicate? = nil, completion: @escaping ([NSManagedObject]) -> Void) {
        var answers: [NSManagedObject] = []
        let managedContext = getContext()
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "\(AssessmentAnswer.self)")
        fetchRequest.predicate = predicate
        do {
            answers = try managedContext?.fetch(fetchRequest) ?? []
        } catch let error as NSError {
            print(error)
        }
        completion(answers)
    }

    private func getExistingAnswer(
        _ assessmentID: Int?,
        _ studentID: Int?,
        _ questionID: Int?,
        _ module: String,
        completion: @escaping (NSManagedObject?) -> Void
    ) {
        let assessmentIDPredicate = NSPredicate(format: "assessmentId == %d", assessmentID ?? -1)
        let questionIdPredicate = NSPredicate(format: "questionId == %d", questionID ?? -1)
        let studentIdPredicate = NSPredicate(format: "studentId == %d", studentID ?? -1)
        let modulePredicate = NSPredicate(format: "module == %@", module)
        let compoundPredicate = NSCompoundPredicate(
            type: .and, subpredicates:
            [
                assessmentIDPredicate,
                questionIdPredicate,
                studentIdPredicate,
                modulePredicate
            ]
        )
        fetch(withPredicate: compoundPredicate) { managedObjects in
            completion(managedObjects.first)
        }
    }

    // MARK: - Public functions

    func fetchAll(completion: @escaping ([NSManagedObject]) -> Void) {
        fetch(completion: completion)
    }
    
    func delete() {
        let managedContext = getContext()
        managedContext?.delete(self)
    }
    
    func deleteAll(forAssessment assessment: Assessment, completion: @escaping ([NSManagedObject]) -> Void) {
        delete(withPredicate: NSPredicate(format: "id == %d", assessment.id ?? -1), completion: completion)
    }

    func createIfNeeded(
        assessmentID: Int?,
        studentID: Int?,
        questionID: Int?,
        module: String,
        completion: @escaping (AssessmentAnswer) -> Void
    ) {
        getExistingAnswer(assessmentID, studentID, questionID, module) { managedObject in
            if let answer = managedObject as? AssessmentAnswer {
                completion(answer)
            } else {
                guard let managedContext = self.getContext(),
                    let entity = NSEntityDescription.entity(
                        forEntityName: "\(AssessmentAnswer.self)",
                        in: managedContext
                    )
                    else { return }
                let answer = AssessmentAnswer(entity: entity, insertInto: managedContext)
                answer.setValue(assessmentID, forKey: "assessmentId")
                answer.setValue(questionID, forKey: "questionId")
                answer.setValue(studentID, forKey: "studentId")
                answer.setValue(module, forKey: "module")
                completion(answer)
            }
        }
    }

    func fetchExistingAnswer(
        assessmentID: Int?,
        studentID: Int?,
        questionID: Int?,
        module: String,
        completion: @escaping (AssessmentAnswer?) -> Void
    ) {
        getExistingAnswer(assessmentID, studentID, questionID, module) { managedObject in
            completion(managedObject as? AssessmentAnswer)
        }
    }

}
