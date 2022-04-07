//
//  ChatsViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 16.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import RxCocoa
import RxSwift
import RxRelay
import RealmSwift

class ChatsViewModel {
    
    var activeChats: [MChat]
    var waitingChats: [MChat]
    
    var info = BehaviorRelay<(String,String)?>(value: nil)
    var newWaitingChatRequest = BehaviorRelay<MChat?>(value: nil)
    var newMessageInActiveChat = BehaviorRelay<MChat?>(value: nil)
    var chatChangedFromWaitingToActive = BehaviorRelay<MChat?>(value: nil)
    var chatsChangedUpdate = BehaviorRelay<[MChat]>(value: [])
    var sendingError = BehaviorRelay<Error?>(value: nil)
    var managers: ProfileManagersContainerProtocol
    var token: NotificationToken!
    
    private var currentUser: MUser {
        return managers.currentUser
    }
    private var chatManager: ChatsManager {
        return managers.chatsManager
    }
    
    var userName: String {
        return currentUser.userName
    }
    var user: MUser {
        return currentUser
    }
    
    var title: String {
        return "Чаты"
    }
    
    func filteredActiveChats(with searchText: String) -> [MChat] {
        return activeChats.filter { $0.friendUser!.containts(text: searchText) }
    }
    
    init(managers: ProfileManagersContainerProtocol) {
        self.managers = managers
        self.waitingChats = managers.chatsManager.waitingChatsBase.filter { managers.currentUser.id != $0.hideForID && $0.lastMessage != nil }.sorted { $0.lastMessage!.date! > $1.lastMessage!.date! }
        self.activeChats = managers.chatsManager.activeChatsBase.filter { !$0.listMessages.isEmpty }.sorted {
            return $0.lastMessage!.date! > $1.lastMessage!.date! }
        initObservers()
    }
    
    deinit {
        removeObservers()
        token.invalidate()
    }
}

//MARK: Delegate
extension ChatsViewModel {
    
    func changeChatStatus(chat: MChat) {
        chatManager.changeChatStatusSend(chat: chat)
    }
    
    func removeWaitingChat(chat: MChat) {
        chatManager.removeWaitingChat(chat: chat)
    }
    
    func removeActiveChat(chat: MChat) {
        chatManager.removeActiveChat(chat: chat)
    }
}

//MARK: Observers
extension ChatsViewModel {
    
    enum NotificationName: String, CaseIterable {
        case chatChangedFromWaitingToActive
        case newMessageInActiveChat
        case info
        case newWaitingChatRequest
        case chatsChanged
        case error
        
        var userInfoKey: String? {
            return self.rawValue
        }
        
        var NSNotificationName: NSNotification.Name {
            return NSNotification.Name(self.rawValue)
        }
    }
    
    private func initObservers() {
        token = RealmManager.realm?.observe { [weak self] (_, _) in
            guard let self = self else { return }
            self.waitingChats = self.chatManager.waitingChatsBase.filter { self.currentUser.id != $0.hideForID && $0.lastMessage != nil }.sorted { $0.lastMessage!.date! > $1.lastMessage!.date! }
            self.activeChats = self.chatManager.activeChatsBase.filter { !$0.listMessages.isEmpty }.sorted { $0.lastMessage!.date! > $1.lastMessage!.date! }
        }
        for name in NotificationName.allCases {
            switch name {
            case .chatChangedFromWaitingToActive:
                NotificationCenter.default.addObserver(self, selector: #selector(changedChatStatus), name: name.NSNotificationName, object: nil)
            case .newMessageInActiveChat:
                NotificationCenter.default.addObserver(self, selector: #selector(newMessageUpdate), name: name.NSNotificationName, object: nil)
            case .info:
                NotificationCenter.default.addObserver(self, selector: #selector(infoRecived), name: name.NSNotificationName, object: nil)
            case .newWaitingChatRequest:
                NotificationCenter.default.addObserver(self, selector: #selector(newChatRequest), name: name.NSNotificationName, object: nil)
            case .chatsChanged:
                NotificationCenter.default.addObserver(self, selector: #selector(chatsChanged), name: name.NSNotificationName, object: nil)
            case .error:
                NotificationCenter.default.addObserver(self, selector: #selector(handlingError(notification:)), name: name.NSNotificationName, object: nil)
            }
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: Update Models
private extension ChatsViewModel {
    
    @objc func handlingError(notification: Notification) {
        guard let error = notification.userInfo?["error"] as? Error else { return }
        sendingError.accept(error)
    }
    
    @objc func chatsChanged(notification: Notification) {
        guard let userInfo = notification.userInfo, let chats = userInfo[NotificationName.chatsChanged.userInfoKey!] as? [MChat] else { return }
        let filtered = chats.filter { !(!$0.active && $0.hideForID == self.currentUser.id) }
        chatsChangedUpdate.accept(filtered)
    }
    
    @objc func changedChatStatus(notification: Notification) {
        guard let userInfo = notification.userInfo, let changeChat = userInfo[NotificationName.chatChangedFromWaitingToActive.userInfoKey!] as? MChat else { return }
        chatChangedFromWaitingToActive.accept(changeChat)
    }
    
    @objc func newChatRequest(notification: Notification) {
        guard let userInfo = notification.userInfo, let chat = userInfo[NotificationName.newWaitingChatRequest.userInfoKey!] as? MChat else { return }
        newWaitingChatRequest.accept(chat)
    }
    
    @objc func infoRecived(notification: Notification) {
        guard let userInfo = notification.userInfo, let messageInfo = userInfo[NotificationName.info.userInfoKey!] as? (String,String) else { return }
        info.accept(messageInfo)
    }
    
    @objc func newMessageUpdate(notification: Notification) {
        guard let userInfo = notification.userInfo, let chat = userInfo[NotificationName.newMessageInActiveChat.userInfoKey!] as? MChat else { return }
        newMessageInActiveChat.accept(chat)
    }
}

