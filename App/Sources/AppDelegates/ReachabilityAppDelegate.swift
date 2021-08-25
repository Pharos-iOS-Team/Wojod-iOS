// Copyright © 2020 Pharos Solutions. All rights reserved.

import Reachability
import SwiftyUserDefaults
import UIKit

enum ConnectionContext {
    static var isDisconnectedBefore = Bool()
}

enum ConnectionState {
    case connected
    case notConnected
}

class ReachabilityAppDelegate: AppDelegateType {
    static var connectionState: ConnectionState = .connected

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        reachabilitySetup()
        return true
    }

    func reachabilitySetup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: .reachabilityChanged,
            object: Reachability.shared
        )
        try? Reachability.shared?.startNotifier()
    }

    @objc
    func reachabilityChanged(_ note: NSNotification) {
        guard let reachability = note.object as? Reachability else { return }
        if reachability.reachable, ConnectionContext.isDisconnectedBefore {
            ReachabilityAppDelegate.connectionState = .connected
            NotificationCenter.default.post(name: .internetConnectionChangedNotification, object: nil)
        } else if !reachability.reachable {
            ConnectionContext.isDisconnectedBefore = true
            ReachabilityAppDelegate.connectionState = .notConnected
            NotificationCenter.default.post(name: .internetConnectionChangedNotification, object: nil)
        }
    }
}

extension NSNotification.Name {
    static let internetConnectionChangedNotification = NSNotification.Name("internetChangedNotification")
}
