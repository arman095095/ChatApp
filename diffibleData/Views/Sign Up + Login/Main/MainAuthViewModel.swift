//
//  MainAuthViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseAuth

class MainAuthViewModel {
    
    private var authManager: FirebaseAuthManager {
        return authManagers.authManager
    }

    var authManagers: AuthManagersContainerProtocol
    
    init(authManagers: AuthManagersContainerProtocol) {
        self.authManagers = authManagers
    }
    
    var successLoginHandler: ((MUser) -> ())?
    var successSignUpHandler: ((User) -> ())?
    var failureSignUpHandler: ((Error) -> ())?
    var removedUserHandler: ((MUser, Error) -> ())?
    var successRecoverHandler: ((MUser) -> ())?
    var failureRecoverHandler: ((Error) -> ())?
    
    func cancelRecover() {
        FirebaseAuthManager.signOut(complition: { _ in  })
    }
    
    func recoverProfile(user: MUser) {
        authManager.recoverUserProfile(user: user) { [weak self] (result) in
            switch result {
            case .success(let muser):
                self?.successRecoverHandler?(muser)
            case .failure(let error):
                self?.failureRecoverHandler?(error)
            }
        }
    }
}
