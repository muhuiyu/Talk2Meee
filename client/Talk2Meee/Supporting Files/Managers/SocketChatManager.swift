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
    
    private var conversationID: String?
    
    init() {
        manager = SocketManager(socketURL: URL(string: "http://192.168.11.61:3000")!, config: [.log(true), .compress, .forceWebsockets(true), .reconnectWait(10)])
        socket = manager.defaultSocket
        configureHandlers()
    }
}

extension SocketChatManger {
    func connect() {
        guard let userID = UserManager.shared.currentUserID else { return }
        socket.connect(withPayload: [ "userId": userID ])
    }
    func disconnect() {
        socket.disconnect()
    }
    func subscribleToChats() {
        // subscribe to chats
        let chatIDs = DatabaseManager.shared.getAllChats().map { $0.id }
        socket.emit("subscribe", chatIDs)
    }
    func sendMessage(_ message: ChatMessage) {
        socket.emit("sendMessage", message)
    }
//    func userJoinOnConnect(user: User) {
//        let u: [String: String] = ["sessionId": socket.sid!, "username": user.username]
//        self.socket.emit("userJoin", with: [u])
//    }
//
//    func handleNewMessage(handler: @escaping (_ message: Message) -> Void) {
//        socket.on("newMessage") { (data, ack) in
//            let msg = data[0] as! [String: Any]
//            let usr = msg["user"] as! [String: Any]
//            let user = User(sessionId: usr["sessionId"] as! String, username: usr["username"] as! String)
//            let message = Message(user: user, message: msg["message"] as! String)
//            handler(message)
//        }
//    }
//
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

// MARK: - Handlers
extension SocketChatManger {
    private func configureHandlers() {
        socket.on(clientEvent: .connect) { data, ack in
            return
        }
        socket.on("receiveMessage") { data, ack in
            DatabaseManager.shared.receiveMessage(data[0])
        }
        socket.onAny({
            print("Got event: \($0.event), with items: \($0.items!)")
        })
    }
}
