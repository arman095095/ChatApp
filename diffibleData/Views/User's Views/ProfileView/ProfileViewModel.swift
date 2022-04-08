//
//  SendMessageViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRelay
import Foundation

class ProfileViewModel {
    
    private var friend: MUser?
    private var currentUser: MUser
    var updatedUser = BehaviorRelay<Bool>.init(value: true)
    var iamBlocked = BehaviorRelay<Bool?>.init(value: nil)
    var sendingError = BehaviorRelay<Error?>.init(value: nil)
    var successBlocking = BehaviorRelay<Bool>.init(value: false)
    private let root: Bool

    var chatsManager: ChatsManager {
        return managers.chatsManager
    }
    var firestoreManager: FirestoreManager {
        return managers.firestoreManager
    }
    var managers: ProfileManagersContainerProtocol
    
    init(friend: MUser?, root: Bool, managers: ProfileManagersContainerProtocol) {
        self.currentUser = managers.currentUser
        self.managers = managers
        self.friend = friend
        self.root = root
        updateProfileInfo()
    }
    
    var tabBarHidden: Bool {
        return !root
    }
    
    var userCurrent: MUser {
        return currentUser
    }
    
    var imageURL: URL? {
        if let friend = friend {
            return URL(string: friend.photoURL)
        } else {
            return URL(string: currentUser.photoURL)
        }
    }
    
    var info: String {
        if let friend = friend {
            return friend.info
        } else {
            return currentUser.info
        }
    }
    
    var allowedWrite: Bool {
        return !user.removed && !currentUser.iamblockedIds.contains(user.id!)
    }
    
    var placeholder: String {
        return allowedWrite ? "Напишите сообщение" : "Доступ ограничен"
    }
    
    var title: String {
        if let friend = friend {
            return friend.name
        }
        else {
            return currentUser.name
        }
    }
    
    var name: String {
        if let friend = friend {
            return friend.name + ", " + "\(DateFormatManager().getAge(date: friend.birthday))" }
        else {
            return currentUser.name  + ", " + "\(DateFormatManager().getAge(date: currentUser.birthday))"
        }
    }
    
    var countryCity: String {
        if let friend = friend {
            return friend.countryCityName }
        else {
            return currentUser.countryCityName
        }
    }
    
    var postsCount: Int {
        if let friend = friend {
            return friend.postsCount
        }
        else {
            return currentUser.postsCount
        }
    }
    
    var user: MUser {
        if let friend = friend {
            return friend
        }
        else {
            return currentUser
        }
    }
    
    var yourProfile: Bool {
        return friend == nil
    }
}

//MARK: Communications
extension ProfileViewModel {
    
    func sendMessage(messageText: String?) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            sendingError.accept(ConnectionError.noInternet)
            return
        }
        guard let messageText = messageText, !messageText.isEmpty, let friend = friend  else { return }
        if currentUser.iamblockedIds.contains(friend.id!) {
            iamBlocked.accept(true)
            return
        } else {
            iamBlocked.accept(false)
        }
        let message = MMessage(sender: currentUser, adress: friend, content: messageText)
        chatsManager.sendMessage(message: message)
    }
    
    private func blockUser() {
        guard !yourProfile, let blocked = blocked, !blocked else { return }
        self.currentUser.blockedIds.append(user.id!)
        firestoreManager.blockUser(user: user) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.successBlocking.accept(true)
            case .failure(let error):
                guard let index = self.currentUser.blockedIds.firstIndex(of: self.user.id!) else { return }
                self.currentUser.blockedIds.remove(at: index)
                self.sendingError.accept(error)
            }
        }
    }
    
    private var blocked: Bool? {
        guard !yourProfile else { return nil }
        return userCurrent.blockedIds.contains(user.id!)
    }
    
    var titleForBlocking: String {
        guard let blocked = blocked else { return "" }
        return blocked ? "Разблокировать" : "Заблокировать"
    }
    
    var titleForBlockingResult: String {
        guard let blocked = blocked else { return "" }
        return blocked ? "Пользователь заблокирован" : "Пользователь разблокирован"
    }
    
    
    
    func blockingAction() {
        guard let blocked = blocked else { return }
        if blocked {
            unblockUser()
        } else {
            blockUser()
        }
    }
    
    private func unblockUser() {
        guard !yourProfile, let blocked = blocked, blocked  else { return }
        guard let index = currentUser.blockedIds.firstIndex(of: user.id!) else { return }
        currentUser.blockedIds.remove(at: index)
        firestoreManager.unblockUser(user: user) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.successBlocking.accept(true)
            case .failure(let error):
                self.currentUser.blockedIds.append(self.user.id!)
                self.sendingError.accept(error)
            }
        }
    }
}

//MARK: Operations with Profile
extension ProfileViewModel {
    
    func updateProfileInfo() {
        firestoreManager.getUserProfileForShow(userID: user.id!) { [weak self] (result) in
            switch result {
            case .success(let muser):
                if let _ = self?.friend {
                    self?.friend = muser
                }
                self?.updatedUser.accept(true)
            case .failure(let error):
                self?.sendingError.accept(error)
            }
        }
    }
}

