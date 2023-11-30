//
//  SocketChatManger.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/21/23.
//

import Foundation
import SocketIO

class SocketChatManger {
    
    static let shared = SocketChatManger()
    
    private let manager: SocketManager
    private var socket: SocketIOClient!
    private var resetAck: SocketAckEmitter?
    
    private var messageQueue = [ChatMessage]()
    
    private var conversationID: String?
    
    init() {
//        let url = "http://192.168.1.204:3000"
        let url = "https://talk2meee.onrender.com"
        manager = SocketManager(socketURL: URL(string: url)!, config: [.log(true), .compress, .forceWebsockets(true), .reconnectWait(10)])
        socket = manager.defaultSocket
        configureHandlers()
    }
}

// MARK: - Emit
extension SocketChatManger {
    func connect() {
        guard let userID = UserManager.shared.currentUserID, let token = UserManager.shared.getFCMToken() else { return }
        socket.connect(withPayload: [ "userId": userID, "token": token ])
    }
    func disconnect() {
        socket.disconnect()
    }
    func subscribleToChats() {
        let chatIDs = DatabaseManager.shared.getAllChats().map { $0.id }
        socket.emit("subscribe", chatIDs)
    }
    func sendMessage(_ message: ChatMessage) {
        messageQueue.append(message)
        socket.emit("sendMessage", message)
    }
    func emitUserTyping(in chatID: ChatID) {
        guard let user = UserManager.shared.getChatUser() else { return }
        socket.emit("userTyping", [ "userID": user.id, "chatID": chatID ])
    }
    func emitUserStoppedTyping(in chatID: ChatID) {
        guard let user = UserManager.shared.getChatUser() else { return }
        socket.emit("userStoppedTyping", [ "userID": user.id, "chatID": chatID ])
    }
    func updateLastReadMessage(_ messageID: MessageID, in chatID: ChatID) {
        guard let user = UserManager.shared.getChatUser() else { return }
        socket.emit("updateLastReadMessage", [ "userID": user.id, "messageID": messageID, "chatID": chatID ])
    }
}

// MARK: - Handlers
extension SocketChatManger {
    private func handleReceiveMessage(_ data: [Any]) {
        DatabaseManager.shared.receiveMessage(data[0])
    }
    private func handleDidSendMessage(_ data: [Any]) {
        guard let data = data[0] as? [String: Any], let messageID = data["messageID"] as? String, let chatID = data["chatID"] as? String else { return }
        messageQueue.removeAll(where: { $0.id == messageID && $0.chatID == chatID })
        // TODO: - Update to chat
    }
    private func handleUserTyping(_ data: [Any]) {
//        guard let userID = data[0]["userID"] as? UserID, let chatID = data[0]["chatID"] as? ChatID else { return }
        // TODO: -
    }
    private func handleUserStopTyping(_ data: [Any]) {
        // TODO: -
    }
    private func configureHandlers() {
        socket.on(clientEvent: .connect) { data, ack in
            return
        }
        socket.on("receiveMessage") { data, ack in
            self.handleReceiveMessage(data)
        }
        socket.on("didSendMessage") { data, ack in
            self.handleDidSendMessage(data)
        }
        socket.on("userTyping") { data, ack in
            self.handleUserTyping(data)
        }
        socket.on("userStoppedTyping") { data, ack in
            self.handleUserStopTyping(data)
        }
        socket.onAny({
            print("Got event: \($0.event), with items: \($0.items!)")
        })
    }
//    func handleUserTyping(handler: @escaping () -> Void) {
//        socket.on("userTyping") { (_, _) in
//            handler()
//        }
//    }
//
//    func handleUserStopTyping(handler: @escaping () -> Void) {
//        socket.on("userStopTyping") { (_, _) in
//            handler()
//        }
//    }
//
//    func handleActiveUserChanged(handler: @escaping (_ count: Int) -> Void) {
//        socket.on("count") { (data, ack) in
//            let count = data[0] as! Int
//            handler(count)
//        }
//    }
//
//    func sendMessage(message: Message) {
//        let msg: [String: Any] = ["message": message.message,
//                                  "user": ["sessionId": message.user.sessionId,
//                                           "username": message.user.username
//                                          ]
//                                 ]
//        socket.emit("sendMessage", with: [msg])
//    }
    
}
