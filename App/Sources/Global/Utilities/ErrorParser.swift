// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

import Foundation

enum ErrorParser {
    static func retrieveAlertData(fromError error: NSError?) -> AlertData {
        var title = ""
        var message = ""
        if let errorCode = error?.code {
            (title, message) = matchErrorCode(errorCode, error: error)
        }
        let shouldDiscard = error?.code == 401 || ReachabilityAppDelegate.connectionState != .connected
        let alertData = AlertData(title: title, message: message, shouldDiscard: shouldDiscard)
        return (alertData)
    }

    private static func matchErrorCode(_ errorCode: Int, error: NSError?) -> (title: String, message: String) {
        switch errorCode {
        case 599:
            return timeoutMessage()
        case 403:
            return serviceUnavailableMessage(forError: error)
        case 404:
            return notFoundMessage(forError: error)
        case 409:
            return invalidCredintialsMessage(forError: error)
        case 500:
            return internalServerErrorMessage()
        default:
            return genericErrorMessage()
        }
    }

    private static func timeoutMessage() -> (title: String, message: String) {
        let title = L10n.Global.Titles.error
        let message = L10n.Global.Alerts.somethingWentWrong
        return (title, message)
    }

    private static func unauthorizedAccessMessage(forError error: NSError?) -> (title: String, message: String) {
        var message = L10n.Global.Alerts.somethingWentWrong
        let title = L10n.Global.Titles.unauthorizedAccess
        if let errorMessage = error?.userInfo["message"] as? String {
            message = errorMessage
        }
        return (title, message)
    }

    private static func serviceUnavailableMessage(forError error: NSError?) -> (title: String, message: String) {
        let title = L10n.Global.Titles.error
        var message = L10n.Global.Alerts.somethingWentWrong
        if let errorMessage = error?.userInfo["message"] as? String {
            message = errorMessage
        }
        return (title, message)
    }

    private static func notFoundMessage(forError error: NSError?) -> (title: String, message: String) {
        var message = L10n.Global.Alerts.somethingWentWrong
        let title = L10n.Global.Alerts.notFound
        if let errorMessage = error?.userInfo["message"] as? String {
            message = errorMessage
        }
        return (title, message)
    }

    private static func invalidCredintialsMessage(forError error: NSError?) -> (title: String, message: String) {
        let title = L10n.Global.Titles.error
        let message = error?.userInfo["message"] as? String ?? L10n.Global.Alerts.somethingWentWrong
        return (title, message)
    }

    private static func genericErrorMessage() -> (title: String, message: String) {
        let title = L10n.Global.Titles.error
        let message = L10n.Global.Alerts.somethingWentWrong
        return (title, message)
    }

    private static func internalServerErrorMessage() -> (title: String, message: String) {
        let title = L10n.Global.Titles.serverNotResponding
        let message = L10n.Global.Alerts.somethingWentWrong
        return (title, message)
    }
}
