//
//  MChatManager.swift
//  diffibleData
//
//  Created by Arman Davidoff on 18.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftDate
import RealmSwift

class ChatsManager {
    
    private var currentUser: MUser {
        return managerModel.currentUser
    }
    private var firestoreManager: FirestoreManager {
        managerModel.firestoreManager
    }
    private var messageListener: ListenerRegistration?
    private var typingListener: ListenerRegistration?
    private var chatStatusListener: ListenerRegistration?
    private var friendsListener: ListenerRegistration?
    private var lookedSendedMessagesListener: ListenerRegistration?
    private var token: NotificationToken!
    
    var chats: Results<MChat>
    var activeChatsBase: Results<MChat>
    var waitingChatsBase: Results<MChat>
    
    var managerModel: ManagersModelContainerProtocol
    
    init(managerModel: ManagersModelContainerProtocol) {
        self.managerModel = managerModel
        self.chats = RealmManager.instance!.objects(MChat.self)
        self.activeChatsBase = chats.filter("active == %@", true)
        self.waitingChatsBase = chats.filter("active == %@", false)
        initListeners()
        updateChatsFriendInfo()
        initFriends()
        checkTypingStatus()
        chats.forEach {
            self.sendAllWaitingMessages(in: $0)
        }
    }
    
    deinit {
        messageListener?.remove()
        chatStatusListener?.remove()
        lookedSendedMessagesListener?.remove()
        typingListener?.remove()
        friendsListener?.remove()
        token.invalidate()
    }
}

//MARK: Chat Objects
extension ChatsManager {
    
    var chatsWithNewMessages: [MChat] {
        return chats.filter({ $0.existsNewMessages() })
    }
}

//MARK: Removing
extension ChatsManager {
    
    func removeNewMessages(chat: MChat) {
        if !chat.existsNewMessages() { return }
        chat.removeAllNewMessages()
        notificationFriendMessagesLooked(chat: chat)
        sendNotificationForTabBarBadge(type: .updateChatsBadge,error: nil)
    }
    
    func removeWaitingChat(chat: MChat) {
        removeChat(chat: chat)
        sendNotificationForChats(type: .info, userInfo: ("Успешно", "Чат отклонен"))
    }
    
    func removeActiveChat(chat: MChat) {
        removeChat(chat: chat)
    }
    
    private func removeChat(chat: MChat) {
        let messages = chat.messages.freeze()
        DispatchQueue.global(qos: .background).async {
            messages.forEach {
                self.removeAudioFile(message: $0)
                self.removeImageFile(message: $0)
            }
        }
        chat.removeAllMessages()
        if let index = currentUser.friendsIds.firstIndex(of: chat.friendID!) {
            currentUser.friendsIds.remove(at: index)
        }
        try! RealmManager.instance?.write {
            RealmManager.instance?.delete(chat)
        }
        sendNotificationForTabBarBadge(type: .updateChatsBadge,error: nil)
    }
    
    private func removeImageFile(message: MMessage) {
        if let urlString = message.photoURL, let url = URL(string: urlString) {
            FirebaseStorageManager.shared.deleteDataFrom(url: url)
        }
    }
    
    private func removeAudioFile(message: MMessage) {
        if let url = message.audioURL {
            do {
                try FileManager.default.removeItem(at: FileManager.getDocumentsDirectory().appendingPathComponent(url))
            } catch let error {
                print(error.localizedDescription)
                guard let url = URL(string: url) else { return }
                FirebaseStorageManager.shared.deleteDataFrom(url: url)
            }
        }
    }
}

//MARK: Sended Messages
extension ChatsManager {
    
    func sendMessage(message: MMessage) {
        guard let chat = sendedMessageSave(message: message) else { return }
        firestoreManager.sendMessage(message: message.clone(), complition: { [weak self] (result) in
            switch result {
            case .success:
                self?.markMessageSended(message: message, chat: chat)
                self?.sendNotificationForMessenger(type: .sendMessageUpdated, userInfo: message)
                self?.sendNotificationForChats(type: .newMessageInActiveChat, userInfo: message)
            case .failure(let error):
                self?.sendNotificationForChats(type: .error, userInfo: error)
            }
        })
    }
    
    func sendMessageFromActiveChat(message: MMessage, chat: MChat) {
        appendSendMessageToActiveChat(activeChat: chat, message: message)
        firestoreManager.sendMessage(message: message.clone(), complition: { [weak self] (result) in
            switch result {
            case .success:
                self?.markMessageSended(message: message, chat: chat)
                self?.sendNotificationForChats(type: .newMessageInActiveChat, userInfo: message)
                self?.sendNotificationForMessenger(type: .sendMessageUpdated, userInfo: message)
            case .failure(let error):
                self?.sendNotificationForMessenger(type: .error, userInfo: error)
            }
        })
    }
    
    func sendAllWaitingMessages(in chat: MChat) {
        if chat.notSendedMessages.isEmpty { return }
        let count = chat.notSendedMessages.count
        var i = 0
        chat.notSendedMessages.forEach { message in
            self.firestoreManager.sendMessage(message: message.clone(), complition: { [weak self] (result) in
                switch result {
                case .success:
                    i += 1
                    try! RealmManager.instance?.write {
                        message.date = Date()
                        message.sendingStatus = MMessage.Status.sended.rawValue
                    }
                    if i == count {
                        chat.append(noLooked: chat.notSendedMessages)
                        chat.removeNotSendedMessages()
                        self?.sendNotificationForChats(type: .newMessageInActiveChat, userInfo: message)
                        self?.sendNotificationForMessenger(type: .sendMessageUpdated, userInfo: message)
                    }
                case .failure(let error):
                    self?.sendNotificationForChats(type: .error, userInfo: error)
                }
            })
        }
    }
    
    func markMessageSended(message: MMessage, chat: MChat) {
        try! RealmManager.instance?.write {
            message.date = Date()
            message.sendingStatus = MMessage.Status.sended.rawValue
        }
        guard let index = chat.notSendedMessages.firstIndex(where: { $0.id == message.id }) else { return }
        let removed = chat.notSendedMessages[index]
        chat.append(notLooked: removed)
        try! RealmManager.instance?.write {
            chat.notSendedMessages.remove(at: index)
        }
    }
    
    func markMessagesLooked(friendIds: [String]) {
        friendIds.forEach { friendID in
            guard let firstChat = self.chat(friendID: friendID) else { return }
            if firstChat.notLookedMessages.isEmpty { return }
            try! RealmManager.instance?.write {
                firstChat.notLookedMessages.forEach { $0.sendingStatus = MMessage.Status.looked.rawValue }
            }
            firstChat.removeNotLookedMessages()
            self.sendNotificationForMessenger(type: .sendMessageUpdated, userInfo: friendID)
            guard let lastMessage = firstChat.lastMessage, lastMessage.senderID == currentUser.id else { return }
            self.sendNotificationForChats(type: .chatsChanged, userInfo: [firstChat])
        }
    }
    
    func changeChatStatusSend(chat: MChat) {
        try! RealmManager.instance?.write { chat.active = true }
        notificationFriendChatChangerStatus(chat: chat)
        sendNotificationForChats(type: .info, userInfo: ("Успешно", "Чат стал активным"))
    }
    
    private func sendedMessageSave(message: MMessage) -> MChat? {
        guard let adressID = message.adressID else { return nil }
        if let first = activeChat(friendID: adressID) {
            appendSendMessageToActiveChat(activeChat: first, message: message)
            return first
        }
        else if let first = waitingChat(friendID: adressID) {
            if first.messages.contains(where: { $0.senderID == adressID}) {
                fromWaitingToActive(chat: first, message: message)
                return first
            } else {
                appendSendMessageToWaitingChat(waitingChat: first, message: message)
                return first
            }
        }
        else {
            let chat = createNewWaitingChatForSendMessage(message: message)
            return chat
        }
    }
    
    private func appendSendMessageToActiveChat(activeChat: MChat, message: MMessage) {
        activeChat.append(message)
        activeChat.append(waiting: message)
        sendNotificationForChats(type: .newMessageInActiveChat, userInfo: message)
        sendNotificationForMessenger(type: .newSendedMessage, userInfo: message)
    }
    
    private func appendSendMessageToWaitingChat(waitingChat: MChat, message: MMessage) {
        waitingChat.append(waiting: message)
        waitingChat.append(message)
    }
    
    private func fromWaitingToActive(chat: MChat, message: MMessage) {
        try! RealmManager.instance?.write { chat.active = true }
        chat.append(waiting: message)
        chat.append(message)
        sendNotificationForChats(type: .chatChangedFromWaitingToActive, userInfo: chat)
        notificationFriendChatChangerStatus(chat: chat)
    }
    
    private func createNewWaitingChatForSendMessage(message: MMessage) -> MChat {
        currentUser.friendsIds.append(message.adressID!)
        let chat = MChat(friend: message.adressUser!, current: currentUser)
        chat.append(waiting: message)
        chat.append(message)
        chat.hideForID = currentUser.id
        try! RealmManager.instance?.write { RealmManager.instance?.add(chat) }
        return chat
    }
}

//MARK: Help
extension ChatsManager {
    
    func saveImageAfterLoad(message: MMessage, image: UIImage) {
        if let urlString = message.photoURL, let url = URL(string: urlString) {
            FirebaseStorageManager.shared.deleteDataFrom(url: url)
        }
        try! RealmManager.instance?.write {
            message.imageData = image.jpegData(compressionQuality: 0.4)
            message.photoURL = nil
        }
    }
    
    private func activeChat(friendID: String) -> MChat? {
        return activeChatsBase.filter("friendID == %@", friendID).first
    }
    
    private func waitingChat(friendID: String) -> MChat? {
        return waitingChatsBase.filter("friendID == %@", friendID).first
    }
    
    private func chat(friendID: String) -> MChat? {
        return chats.filter("friendID == %@", friendID).first
    }
    
    private func initFriends() {
        let chatsFreeze = chats.freeze()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.currentUser.friendsIds.append(contentsOf: chatsFreeze.map { $0.friendID! } )
            self?.initFriendsListener()
        }
    }
    
    private func editChatsWithEditedUsers(editedUsers: [MUser]) {
        var changedChats = [MChat]()
        editedUsers.forEach { editedUser in
            if let first = self.chat(friendID: editedUser.id!) {
                if !editedUser.equalForChatUpdate(user: first.friendUser!) {
                    first.friendUser?.updateInfo(with: editedUser)
                    changedChats.append(first)
                    sendNotificationForMessenger(type: .chatEdited, userInfo: first)
                }
            }
        }
        if changedChats.isEmpty { return }
        sendNotificationForChats(type: .chatsChanged, userInfo: changedChats)
    }
    
    private func updateChatsFriendInfo() {
        var changedChats = [MChat]()
        let count = chats.count
        var index = 0
        chats.forEach { chat in
            firestoreManager.getUserProfileForShow(userID: chat.friendID!) { [weak self] (result) in
                index += 1
                switch result {
                case .success(let user):
                    if !user.equalForChatUpdate(user: chat.friendUser!) {
                        chat.friendUser?.updateInfo(with: user)
                        changedChats.append(chat)
                    }
                    if index == count && !changedChats.isEmpty {
                        self?.sendNotificationForChats(type: .chatsChanged, userInfo: changedChats)
                    }
                case .failure(let error):
                    self?.sendNotificationForChats(type: .error, userInfo: error)
                }
            }
        }
    }
}

//MARK: Server Operations
private extension ChatsManager {
    
    func notificationFriendChatChangerStatus(chat: MChat) {
        firestoreManager.sendChatActive(chat: chat) { [weak self] (result) in
            switch result {
            case .success():
                break
            case .failure(let error):
                self?.sendNotificationForChats(type: .error, userInfo: error)
            }
        }
    }
    
    func notificationFriendMessagesLooked(chat: MChat) {
        firestoreManager.sendLookedMessages(chat: chat) { [weak self] (result) in
            switch result {
            case .success():
                break
            case .failure(let error):
                self?.sendNotificationForMessenger(type: .error, userInfo: error)
            }
        }
    }
}

//MARK: Recieved Messages
private extension ChatsManager {
    
    func recievedStatusChange(senderID: String, chatID: String) {
        if let firstChat = waitingChatsBase.first(where: { $0.friendID == senderID }) {
            self.sendNotificationForChats(type: .chatChangedFromWaitingToActive, userInfo: firstChat)
            try! RealmManager.instance?.write { firstChat.active = true }
        }
    }
    
    func appendRecievedMessagesToActiveChat(activeChat: MChat, messages: [MMessage]) {
        guard !messages.isEmpty else { return }
        activeChat.append(ofNew: messages)
        activeChat.append(of: messages)
        sendNotificationForChats(type: .newMessageInActiveChat, userInfo: messages.last!)
        sendNotificationForMessenger(type: .newRecievedMessages, userInfo: messages)
    }
    
    func appendRecievedMessagesToWaitingChat(waitingChat: MChat, messages: [MMessage]) {
        waitingChat.append(ofNew: messages)
        waitingChat.append(of: messages)
    }
    
    func fromWaitingToActive(chat: MChat, messages: [MMessage]) {
        try! RealmManager.instance?.write { chat.active = true }
        chat.append(ofNew: messages)
        chat.append(of: messages)
        sendNotificationForChats(type: .chatChangedFromWaitingToActive, userInfo: chat)
        notificationFriendChatChangerStatus(chat: chat)
    }
    
    func createNewWaitingChatForRecievedMessages(messages: [MMessage]) {
        guard !messages.isEmpty else { return }
        currentUser.friendsIds.append(messages.first!.senderID!)
        let chat = MChat(friend: messages.first!.senderUser!, current: currentUser)
        chat.append(of: messages)
        chat.append(ofNew: messages)
        try! RealmManager.instance?.write { RealmManager.instance?.add(chat) }
        sendNotificationForChats(type: .newWaitingChatRequest, userInfo: chat)
    }
    
    func saveRecievedMessages(messages: [MMessage]) {
        DispatchQueue.global(qos: .userInteractive).async {
            var dict: [String:[MMessage]] = [:]
            messages.forEach {
                let userID = $0.senderID!
                if dict[userID] == nil { dict[userID] = [$0] }
                else {
                    var array = dict[userID]!
                    array.append($0)
                    dict[userID] = array
                }
            }
            dict.forEach { (key, messages) in
                let sorted = messages.sorted { $0.date! < $1.date! }
                dict[key] = sorted
            }
            DispatchQueue.main.async {
                self.saveRecieved(dict: dict)
            }
        }
    }
    
    func saveRecieved(dict: [String: [MMessage]]) {
        for senderID in dict.keys {
            if let messages = dict[senderID] {
                if let first = self.activeChat(friendID: senderID) {
                    self.appendRecievedMessagesToActiveChat(activeChat: first, messages: messages)
                }
                else if let first = self.waitingChat(friendID: senderID) {
                    if first.messages.contains(where: { $0.adressID == senderID}) {
                        self.fromWaitingToActive(chat: first, messages: messages)
                    } else {
                        self.appendRecievedMessagesToWaitingChat(waitingChat: first, messages: messages)
                    }
                }
                else {
                    self.createNewWaitingChatForRecievedMessages(messages: messages)
                }
            }
        }
        self.sendNotificationForTabBarBadge(type: .updateChatsBadge, error: nil)
    }
}

//MARK: Listeners
private extension ChatsManager {
    
    func initFriendsListener() {
        friendsListener = firestoreManager.listenerForUsers(complition: { [weak self] (result) in
            switch result {
            case .success(let users):
                if !users.isEmpty {
                    self?.editChatsWithEditedUsers(editedUsers: users)
                }
            case .failure(_):
                break
            }
        })
    }
    
    func initListeners() {
        messageListener = firestoreManager.listenerForMessages(complition: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
                if messages.isEmpty { return }
                self.saveRecievedMessages(messages: messages)
            case .failure(let error):
                self.sendNotificationForChats(type: .error, userInfo: error)
            }
        })
        
        typingListener = firestoreManager.listenerForTyping(complition: { [weak self] (result) in
            switch result {
            case .success(let ids):
                self?.editTypingChats(friendIDs: ids.0, typing: true)
                self?.editTypingChats(friendIDs: ids.1, typing: false)
            case .failure(let error):
                self?.sendNotificationForMessenger(type: .error, userInfo: error)
            }
        })
        
        lookedSendedMessagesListener = firestoreManager.listenerlookedSendedMessages(complition: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let friendsIds):
                if friendsIds.isEmpty { return }
                self.markMessagesLooked(friendIds: friendsIds)
            case .failure(let error):
                self.sendNotificationForChats(type: .error, userInfo: error)
            }
        })
        
        chatStatusListener = firestoreManager.listenerForChatStatus(complition: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let chats):
                if chats.isEmpty { return }
                chats.forEach { self.recievedStatusChange(senderID: $0.0, chatID: $0.1) }
            case .failure(let error):
                self.sendNotificationForChats(type: .error, userInfo: error)
            }
        })
        
        token = RealmManager.instance?.observe({ [weak self] (notif, realm) in
            guard let self = self else { return }
            self.chats = realm.objects(MChat.self)
            self.activeChatsBase = self.chats.filter("active == %@", true)
            self.waitingChatsBase = self.chats.filter("active == %@", false)
        })
    }
}

//MARK: Notifications Sending
private extension ChatsManager {
    
    func sendNotificationForChats(type: ChatsViewModel.NotificationName, userInfo: Any?) {
        switch type {
        case .info:
            if let userInfo = userInfo, let messageInfo = userInfo as? (String,String) {
                let dict = [type.userInfoKey: messageInfo]
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
            }
        case .newWaitingChatRequest:
            if let userInfo = userInfo, let chat = userInfo as? MChat {
                let dict = [type.userInfoKey: chat]
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
            }
        case .newMessageInActiveChat:
            if let userInfo = userInfo, let message = userInfo as? MMessage {
                if let chat = activeChatsBase.filter("friendID == %@", message.adressID!).first {
                    let dict = [type.userInfoKey!: chat]
                    NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
                } else if let chat = activeChatsBase.filter("friendID == %@", message.senderID!).first {
                    let dict = [type.userInfoKey!: chat]
                    NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
                }
            }
        case .chatChangedFromWaitingToActive:
            if let userInfo = userInfo, let changeChat = userInfo as? MChat {
                let dict = [type.userInfoKey: changeChat]
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
            }
        case .chatsChanged:
            if let userInfo = userInfo, let chats = userInfo as? [MChat] {
                let dict = [type.userInfoKey: chats]
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
            }
        case .error:
            if let error = userInfo as? Error {
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil,userInfo: ["error": error])
            }
        }
    }
    
    func sendNotificationForMessenger(type: MessangerViewModel.NotificationName, userInfo: Any?) {
        switch type {
        case .newSendedMessage:
            guard let message = userInfo as? MMessage else { return }
            let dict = [type.userInfoKey!: message]
            NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
        case .newRecievedMessages:
            guard let messages = userInfo as? [MMessage] else { return }
            let dict = [type.userInfoKey!: messages]
            NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
        case .sendMessageUpdated:
            guard let message = userInfo as? MMessage else {
                guard let chatID = userInfo as? String else { return }
                let dict = [type.userInfoKey!: chatID]
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
                return }
            let dict = [type.userInfoKey!: message]
            NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
        case .chatEdited:
            if let userInfo = userInfo, let chatEdited = userInfo as? MChat {
                let dict = [type.userInfoKey: chatEdited]
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: dict)
            }
        case .error:
            if let error = userInfo as? Error {
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil,userInfo: ["error": error])
            }
        }
    }
    
    func sendNotificationForTabBarBadge(type: MainTabBarViewModel.NotificationName, error: Error?) {
        switch type {
        case .updateChatsBadge:
            NotificationCenter.default.post(name: type.NSNotificationName, object: nil)
        case .error:
            if let error = error {
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil,userInfo: ["error": error])
            }
        }
    }
}

//MARK: Typing
extension ChatsManager {
    
    func checkTypingStatus() {
        var changedChats = [MChat]()
        let count = activeChatsBase.count
        var index = 0
        activeChatsBase.forEach { activeChat in
            self.firestoreManager.checkTypingStatus(chat: activeChat) { [weak self] (result) in
                index += 1
                if result != activeChat.typing {
                    try! RealmManager.instance?.write { activeChat.typing = result }
                    changedChats.append(activeChat)
                }
                if index == count && !changedChats.isEmpty {
                    self?.sendNotificationForChats(type: .chatsChanged, userInfo: changedChats)
                }
            }
        }
    }
    
    func sendTypingBegin(chat: MChat) {
        firestoreManager.sendTyping(chat: chat) { [weak self] (result) in
            switch result {
            case .success():
                break
            case .failure(let error):
                self?.sendNotificationForMessenger(type: .error, userInfo: error)
            }
        }
    }
    
    func sendTypingFinish(chat: MChat) {
        firestoreManager.sendFinishTyping(chat: chat) { [weak self] (result) in
            switch result {
            case .success():
                break
            case .failure(let error):
                self?.sendNotificationForMessenger(type: .error, userInfo: error)
            }
        }
    }
    
    func editTypingChats(friendIDs: [String], typing: Bool) {
        if friendIDs.isEmpty { return }
        var typingChats = [MChat]()
        friendIDs.forEach { id in
            if let chat = activeChat(friendID: id) {
                try! RealmManager.instance?.write { chat.typing = typing }
                typingChats.append(chat)
                self.sendNotificationForMessenger(type: .chatEdited, userInfo: chat)
            }
        }
        sendNotificationForChats(type: .chatsChanged, userInfo: typingChats)
    }
}

