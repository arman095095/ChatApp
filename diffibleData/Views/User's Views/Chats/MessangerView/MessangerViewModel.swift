//
//  MessangerViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 16.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import RxCocoa
import MessageKit
import RxSwift
import RxRelay

class MessangerViewModel {
    
    private var currentUser: MUser {
        return managers.currentUser
    }
    private var chatManager: ChatsManager {
        return managers.chatsManager
    }
    private var firestoreManager: FirestoreManager {
        return managers.firestoreManager
    }
    private var audioRecorder: AudioMessageRecorder {
        return audioManagers.recorder
    }
    private var audioPlayer: AudioMessagePlayer {
        return audioManagers.player
    }
    private var increamentCount: Int {
        return LimitsConstants.messages
    }
    private var timer: Timer?
    private var currentUserTyping = false
    private var chat: MChat
    private var friend: MUser!
    private var count = 0
    var canLoadMore = true
    var iamBlocked = BehaviorRelay<Bool>.init(value: false)
    var newSendMessage = BehaviorRelay<MMessage?>(value: nil)
    var newRecievedMessages = BehaviorRelay<[MMessage]?>(value: nil)
    var sendMessageUpdate = BehaviorRelay<Bool>.init(value: false)
    var sendingError = BehaviorRelay<Error?>(value: nil)
    var chatEdited = BehaviorRelay<Bool>.init(value: false)
    var managers: ProfileManagersContainerProtocol
    private var audioManagers: AudioManagersContainerProtocol
    
    init(chat: MChat, managers: ProfileManagersContainerProtocol, audioManagers: AudioManagersContainerProtocol) {
        self.audioManagers = audioManagers
        self.managers = managers
        self.chat = chat
        self.friend = chat.friendUser
        let _ = self.loadMoreMessages()
        canLoadMore = true
        self.initObservers()
        self.readAllNewMessages()
    }
    
    deinit {
        removeObservers()
        chatManager.sendTypingFinish(chat: chat)
    }
    
    var user: MUser {
        return currentUser
    }
    
    var friendUser: MUser {
        return friend
    }
    
    var allowedWrite: Bool {
        return !friend.removed && !currentUser.iamblockedIds.contains(friend.id!)
    }
    
    var currentChat: MChat {
        return chat
    }
    
    var titleDescription: String? {
        if chat.typing { return "печатает" }
        if friend.online { return "в сети"}
        guard let lastActivity = friend.lastActivity else { return nil }
        let description = DateFormatManager().getLastActivityDescription(date: lastActivity)
        return "был(а) в сети \(description)"
    }
    
    var placeholder: String {
        return allowedWrite ? "Напишите сообщение" : "Доступ ограничен"
    }
    
    var friendUserName: String {
        return friend.name
    }
    
    var friendImageURL: URL? {
        return URL(string: friend.photoURL)
    }
}

//MARK: For DataSource
extension MessangerViewModel {
    
    func message(at indexPath: IndexPath) -> MMessage {
        let index = chat.messagesCount - count + indexPath.section
        let message = chat.messages[index]
        return message
    }
    
    func firstMessageTime(at indexPath: IndexPath) -> String {
        let messageValue = message(at: indexPath)
        return DateFormatManager().convertForLabel(from: messageValue.date!)
    }
    
    var messagesCount: Int {
        return count
    }
}

//MARK: Messages Load
extension MessangerViewModel {
    
    func loadMoreMessages() -> Bool {
        canLoadMore = false
        if messagesCount == chat.messagesCount {
            return false
        }
        if  messagesCount + increamentCount <= chat.messagesCount {
            self.count += increamentCount
            return true
        } else {
            self.count = chat.messagesCount
            return true
        }
    }
}

//MARK: Operations with Message
extension MessangerViewModel {
    
    func saveImageAfterLoad(message: MessageType, image: UIImage) {
        let mmessage = (message as! MockPhotoMessage).message
        chatManager.saveImageAfterLoad(message: mmessage, image: image)
    }
    
    private func readAllNewMessages() {
        chatManager.removeNewMessages(chat: chat)
    }
    
    func sendMessage(text: String) {
        if currentUser.iamblockedIds.contains(friend.id!) {
            iamBlocked.accept(true)
            return
        }
        let message = MMessage(sender: currentUser, adress: friend, content: text)
        chatManager.sendMessageFromActiveChat(message: message, chat: chat)
    }
    
    func sendPhoto(photo: UIImage, ratio: CGFloat) {
        if currentUser.iamblockedIds.contains(friend.id!) {
            iamBlocked.accept(true)
            return
        }
        let message = MMessage(sender: currentUser, adress: friend, content: "")
        message.imageData = photo.jpegData(compressionQuality: 0.4)
        message.imageRatio = Double(ratio)
        chatManager.sendMessageFromActiveChat(message: message, chat: chat)
    }
}

//MARK: Observers
extension MessangerViewModel {
    
    enum NotificationName: String, CaseIterable {
        case newSendedMessage
        case newRecievedMessages
        case sendMessageUpdated
        case chatEdited
        case error
        
        var userInfoKey: String? {
            return self.rawValue
        }
        
        var NSNotificationName: NSNotification.Name {
            return NSNotification.Name(self.rawValue)
        }
    }
    
    private func initObservers() {
        for name in NotificationName.allCases {
            switch name {
            case .newSendedMessage:
                NotificationCenter.default.addObserver(self, selector: #selector(sendedNewMessage), name: name.NSNotificationName, object: nil)
            case .newRecievedMessages:
                NotificationCenter.default.addObserver(self, selector: #selector(recievedNewMessages(notification:)), name: name.NSNotificationName, object: nil)
            case .sendMessageUpdated:
                NotificationCenter.default.addObserver(self, selector: #selector(sendMessageUpdated(notification:)), name: name.NSNotificationName, object: nil)
            case .chatEdited:
                NotificationCenter.default.addObserver(self, selector: #selector(chatEdited(notification:)), name: name.NSNotificationName, object: nil)
            case .error:
                NotificationCenter.default.addObserver(self, selector: #selector(handlingError(notification:)), name: name.NSNotificationName, object: nil)
            }
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: Update models
private extension MessangerViewModel {
    
    @objc func handlingError(notification: Notification) {
        guard let error = notification.userInfo?["error"] as? Error else { return }
        sendingError.accept(error)
    }
    
    @objc func sendedNewMessage(notification: Notification) {
        guard let userInfo = notification.userInfo, let message = userInfo[NotificationName.newSendedMessage.userInfoKey!] as? MMessage else { return }
        if message.senderID == currentUser.id && message.adressID == friend.id {
            count = chat.messagesCount <= increamentCount ? chat.messagesCount : increamentCount
            canLoadMore = true
            newSendMessage.accept(message)
        }
    }
    
    @objc func recievedNewMessages(notification: Notification) {
        guard let userInfo = notification.userInfo, let messages = userInfo[NotificationName.newRecievedMessages.userInfoKey!] as? [MMessage] else { return }
        guard !messages.isEmpty else { return }
        if messages.first!.senderID == friend.id && messages.first!.adressID == currentUser.id {
            readAllNewMessages()
            count += messages.count
            canLoadMore = true
            newRecievedMessages.accept(messages)
        }
    }
    
    @objc func sendMessageUpdated(notification: Notification) {
        guard let userInfo = notification.userInfo, let message = userInfo[NotificationName.sendMessageUpdated.userInfoKey!] as? MMessage else {
            guard let userInfo = notification.userInfo, let friendID = userInfo[NotificationName.sendMessageUpdated.userInfoKey!] as? String else { return
            }
            if friendID == chat.friendID! {
                sendMessageUpdate.accept(true)
            }
            return
        }
        if message.adressID == friend.id && message.senderID == currentUser.id {
            sendMessageUpdate.accept(true)
        }
    }
    
    @objc func chatEdited(notification: Notification) {
        guard let userInfo = notification.userInfo, let chat = userInfo[NotificationName.chatEdited.userInfoKey!] as? MChat else { return }
        if chat.friendID! == friend.id {
            self.chat = chat
            self.friend = chat.friendUser
            chatEdited.accept(true)
        }
    }

}

//MARK: Audio Messages
extension MessangerViewModel {
    
    func beginRecord() {
        audioPlayer.stopAnyOngoingPlaying()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.audioRecorder.beginRecord()
        }
    }
    
    func cancelRecord() {
        audioRecorder.cancelRecord()
    }
    
    func finishRecord() {
        if currentUser.iamblockedIds.contains(friend.id!) {
            iamBlocked.accept(true)
            return
        }
        guard let audioInfo = audioRecorder.stopRecord() else { return }
        let message = MMessage(sender: currentUser, adress: friend, content: "", audioURL: audioInfo.0, audioDuration: audioInfo.1)
        chatManager.sendMessageFromActiveChat(message: message, chat: chat)
    }
    
    func configureAudioCell(cell: AudioMessageCell, message: MessageType) {
        audioPlayer.configureAudioCell(cell, message: message)
    }
    
    func playAudioMessage(message: MessageType, cell: AudioMessageCell) {
        guard audioPlayer.state != .stopped else {
            audioPlayer.playSound(for: message, in: cell)
            return
        }
        if audioPlayer.playingMessage?.messageId == message.messageId {
            if audioPlayer.state == .playing {
                audioPlayer.pauseSound(for: message, in: cell)
            } else {
                audioPlayer.resumeSound()
            }
        } else {
            audioPlayer.stopAnyOngoingPlaying()
            audioPlayer.playSound(for: message, in: cell)
        }
    }
}

//MARK: Typing
extension MessangerViewModel {
    
    func currentUserBeginTyping(text: String) {
        if text.isEmpty || text == "" {
            self.chatManager.sendTypingFinish(chat: self.chat)
            self.currentUserTyping = false
            return
        }
        
        if !currentUserTyping {
            chatManager.sendTypingBegin(chat: chat)
            currentUserTyping = true
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.chatManager.sendTypingFinish(chat: self.chat)
            self.currentUserTyping = false
        })
    }
}
