//
//  BlackListViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import RxSwift
import RxRelay
import UIKit

class BlackListViewModel {
    
    private var blockedUsers = [MUser]()
    var updated = BehaviorRelay<Bool>.init(value: false)
    var unlocked = BehaviorRelay<Bool>.init(value: false)
    var error = BehaviorRelay<Error?>.init(value: nil)
    var managers: ProfileManagersContainerProtocol
    private var currentUser: MUser
    private var firestoreManager: FirestoreManager {
        managers.firestoreManager
    }
    
    init(managers: ProfileManagersContainerProtocol) {
        self.managers = managers
        self.currentUser = managers.currentUser
        getBlockedUsers()
    }
    
    func getBlockedUsers() {
        firestoreManager.getBlockedUsers(blocked: currentUser.blockedIds) { [weak self] (result) in
            switch result {
            case .success(let users):
                self?.blockedUsers = users
                self?.updated.accept(true)
            case .failure(let error):
                self?.error.accept(error)
            }
        }
    }
    
    func unblockUser(at indexPath: IndexPath) {
        let user = blockedUsers.remove(at: indexPath.row)
        guard let index = currentUser.blockedIds.firstIndex(where: { $0 == user.id! }) else { return }
        currentUser.blockedIds.remove(at: index)
        firestoreManager.unblockUser(user: user) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.unlocked.accept(true)
            case .failure(let error):
                self?.error.accept(error)
            }
        }
    }
    
    var title: String {
        return "Черный список"
    }
    
    var emptyTitle: String {
        return "Пользователей в черном списке нет"
    }
    
    var headerHeight: CGFloat {
        if currentUser.blockedIds.isEmpty {
            return 250
        } else {
            return 0
        }
    }
    
    var rowHeight: CGFloat {
        return BlackListConstants.heightRow
    }
    
    var numberOfRows: Int {
        return blockedUsers.count
    }
    
    func user(at indexPath: IndexPath) -> MUser {
        return blockedUsers[indexPath.row]
    }
}
