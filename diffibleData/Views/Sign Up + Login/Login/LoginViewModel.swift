//
//  LoginViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseAuth

class LoginViewModel {
    
    private var googleAuthManager: GoogleAuthManager {
        return authManagers.googleAuthManager
    }
    private var authManager: FirebaseAuthManager {
        return authManagers.authManager
    }
    var authManagers: AuthManagersContainerProtocol
    
    init(authManagers: AuthManagersContainerProtocol) {
        self.authManagers = authManagers
    }
    
    var successFullLoginHandler: ((MUser) -> ())? {
        didSet {
            googleAuthManager.successLoginHandler = successFullLoginHandler
        }
    }
    var successPartLoginHandler: ((User) -> ())? {
        didSet {
            googleAuthManager.successSignUpHandler = successPartLoginHandler
        }
    }
    var failureSignUpHandler: ((Error) -> ())? {
        didSet {
            googleAuthManager.failureSignUpHandler = failureSignUpHandler
        }
    }
    var removedUserHandler: ((MUser, Error) -> ())? {
        didSet {
            googleAuthManager.removedUserHandler = removedUserHandler
        }
    }
    var successRecoverHandler: ((MUser) -> ())?
    var failureRecoverHandler: ((Error) -> ())?
    
    
    let checker = Validator()
    
    func signInWithGoogle(present: UIViewController) {
        googleAuthManager.googleSignIn(presenting: present)
    }
    
    func recoverProfile(user: MUser) {
        user.recoverUser()
        authManager.recoverUserProfile(user: user) { [weak self] (result) in
            switch result {
            case .success(let muser):
                self?.successRecoverHandler?(muser)
            case .failure(let error):
                self?.failureRecoverHandler?(error)
            }
        }
    }
    
    func cancelRecover() {
        FirebaseAuthManager.signOut(complition: { _ in })
    }
    
    func login(with email: String?, password: String?) {
        if !checker.checkFilledLogin(email: email, password: password) {
            failureSignUpHandler?(AuthError.notFilled)
            return
        }
        if !checker.mailCorrectForm(email: email!) {
            failureSignUpHandler?(AuthError.incorrectMail)
            return
        }
        authManager.login(email: email!, password: password!) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.authManager.getUserProfile(userID: user.uid) { (result) in
                    switch result {
                    case .success(let muser):
                        self.successFullLoginHandler?(muser)
                    case .failure(let error):
                        if let error = error as? GetUserInfoError {
                            switch error {
                            case .getData:
                                self.successPartLoginHandler?(user)
                            case .convertData:
                                self.successPartLoginHandler?(user)
                            case .profileRemoved(let muser):
                                self.removedUserHandler?(muser,error)
                            }
                        }
                        else { self.failureSignUpHandler?(error) }
                    }
                }
            case .failure(let error):
                self.failureSignUpHandler?(error)
            }
        }
    }
}
