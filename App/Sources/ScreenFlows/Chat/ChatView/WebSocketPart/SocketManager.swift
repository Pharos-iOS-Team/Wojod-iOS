// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import Starscream
import SwiftyUserDefaults

protocol SocketManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
}

class SocketManager {
    private let channelIdentifier: String = "ChatChannel"
    private var socket: Starscream.WebSocket?
    private var conversationID: Int
    private var chatType: ChatType

    // MARK: - Delegates

    weak var delegate: SocketManagerDelegate?

    // MARK: - Initializers

    init(conversationID: Int, chatType: ChatType) {
        self.conversationID = conversationID
        self.chatType = chatType
        initSocketManager()
    }

    // MARK: - Private functions

    private func initSocketManager() {
        let accessToken = KeychainHandler.shared.userToken ?? ""
        let client = Defaults[\.clientKey] ?? ""
        let uid = Defaults[\.uidKey] ?? ""
        var socketUrlString = "\(AppEnvironment.chatBaseURLString)?"
        socketUrlString += "access-token=\(accessToken)"
        socketUrlString += "&uid=\(uid)"
        socketUrlString += "&client=\(client)"
        guard let socketUrl = URL(string: socketUrlString) else { return }
        socket = WebSocket(request: URLRequest(url: socketUrl))
        socket?.delegate = self
    }

    // MARK: - Public functions
    func connect() {
        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
    }
}

// MARK: - WebSocketDelegate
extension SocketManager: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected:
            subscribeToChannel()
        case .text(let message):
            delegate?.didReceiveMessage(message)
        case .error(let error):
            AnalyticsEventLogger.log(error: error?.localizedDescription ?? "Unknown error")
        default:
            return
        }
    }

    private func subscribeToChannel() {
        let parameters = setParamsForSubscribing()
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters)
            guard let params = String(bytes: data, encoding: .utf8) else { return }
            socket?.write(string: params)
        } catch {
            AnalyticsEventLogger.log(error: error.localizedDescription)
        }
    }

    private func setParamsForSubscribing() -> [String: Any] {
        switch chatType {
        case let .teacher(courseID, _):
            let loggedUserDetails = LoggedUserDetails()
            let strChannel = "{\"channel\": \"\(channelIdentifier)\",\"student_id\": \"\(loggedUserDetails.senderId)\",\"course_id\": \"\(courseID)\" }"
            return ["command": "subscribe", "identifier": strChannel]
        case .customerSupport:
            let strChannel = "{\"channel\": \"\(channelIdentifier)\",\"conversation_id\": \"\(conversationID)\",\"conversation\": \"\(true)\" }"
            return ["command": "subscribe", "identifier": strChannel]
        }
    }
}
