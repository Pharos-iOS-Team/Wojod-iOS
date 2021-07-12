// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation
import Starscream
import SwiftyUserDefaults

protocol SocketManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
}

class SocketManager {
    private let channelIdentifier: String = "ChatChannel"
    private var socket: WebSocket?
    private var chatableId: String

    // MARK: - Delegates

    weak var delegate: SocketManagerDelegate?

    // MARK: - Initializers

    init(chatableId: String) {
        self.chatableId = chatableId
        initSocketManager()
    }

    // MARK: - Private functions

    private func initSocketManager() {
        let accessToken = KeychainHandler.shared.userToken ?? ""
        let client = Defaults[\.clientKey] ?? ""
        let uid = Defaults[\.uidKey] ?? ""
        var socketUrlString = "\(Environment.chatBaseURLString)?"
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
    func didReceive(event: WebSocketEvent, client: WebSocket) {
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
        let parameters: [String: Any] = [
            "command": "subscribe",
            "identifier": "{\"channel\":\"\(channelIdentifier)\",\"conversation_id\":\"\(1)\"}",
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters)
            guard let params = String(bytes: data, encoding: .utf8) else { return }
            socket?.write(string: params)
        } catch {
            AnalyticsEventLogger.log(error: error.localizedDescription)
        }
    }
}
