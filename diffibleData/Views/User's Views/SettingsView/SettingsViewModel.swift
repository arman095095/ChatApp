//
//  SettingsViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import RxCocoa
import RxSwift
import RxRelay

class SettingsViewModel {
    
    var successLogout = BehaviorRelay<Bool>.init(value: false)
    var successRemoved = BehaviorRelay<Bool>.init(value: false)
    var error = BehaviorRelay<Error?>.init(value: nil)
    
    var firestoreManager: FirestoreManager {
        return managers.firestoreManager
    }
    var managers: ProfileManagersContainerProtocol
    
    var currentUser: MUser
    
    var title: String {
        return "Настройки"
    }
    
    init(currentUser: MUser, managers: ProfileManagersContainerProtocol) {
        self.currentUser = currentUser
        self.managers = managers
    }
    
    func removeProfile() {
        currentUser.removeUser()
        firestoreManager.removeUserProfile(user: currentUser) { [weak self] (result) in
            switch result {
            case .success(_):
                FirebaseAuthManager.signOut { error in
                    if let error = error {
                        self?.error.accept(error)
                        return
                    }
                    self?.successRemoved.accept(true)
                    RealmManager.deinitalize()
                }
            case .failure(let error):
                self?.error.accept(error)
            }
        }
    }
    
    func logout() {
        FirebaseAuthManager.signOut { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.error.accept(error)
                return
            }
            self.successLogout.accept(true)
            RealmManager.deinitalize()
        }
    }
    
    
}
