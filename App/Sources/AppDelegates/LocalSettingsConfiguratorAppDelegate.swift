// Copyright © 2020 Pharos Solutions. All rights reserved.

import CoreData
import SwiftyUserDefaults
import UIKit

class LocalSettingsConfiguratorAppDelegate: AppDelegateType {
    static var shared = LocalSettingsConfiguratorAppDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        print("\(path)")
        setMinimumBackgroundFetchInterval(application)
        configureParameterOnFreshInstall(application)
        Language.default = .english
        return true
    }

    private func setMinimumBackgroundFetchInterval(_ application: UIApplication) {
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .background && ReachabilityAppDelegate.connectionState == .connected {
            AssessmentSynchronization().startSynchronization()
        }
        completionHandler(.noData)
    }

    private func configureParameterOnFreshInstall(_ application: UIApplication) {
        if Defaults[\.isFreshInstall] {
            KeychainHandler.shared.deleteUserToken()
            Defaults[\.isFreshInstall] = false
            application.applicationIconBadgeNumber = 0
        }
    }

    // MARK: - Core Data Configuration
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Wojood")
            container.loadPersistentStores { storeDescription, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()

        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
}
