//
//  MainAuthViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation
import GoogleSignIn
import FirebaseAuth

class GoogleAuthManager: NSObject, GIDSignInDelegate {
    
    var successLoginHandler: ((MUser) -> ())?
    var successSignUpHandler: ((User) -> ())?
    var failureSignUpHandler: ((Error) -> ())?
    var removedUserHandler: ((MUser, Error) -> ())?
    var authManager: FirebaseAuthManager
    
    init(authManager: FirebaseAuthManager) {
        self.authManager = authManager
        super.init()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func googleSignIn(presenting vc: UIViewController) {
        GIDSignIn.sharedInstance()?.presentingViewController = vc
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        authManager.login(user: user, error: error) { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.authManager.getUserProfile(userID: user.uid) { (result) in
                    switch result {
                    case .success(let muser):
                        self?.successLoginHandler?(muser)
                    case .failure(let error):
                        if let error = error as? GetUserInfoError {
                            switch error {
                            case .getData:
                                self?.successSignUpHandler?(user)
                            case .convertData:
                                self?.successSignUpHandler?(user)
                            case .profileRemoved(let muser):
                                self?.removedUserHandler?(muser,error)
                            }
                        } else {
                            self?.failureSignUpHandler?(error)
                        }
                    }
                }
            case .failure(let error):
                self?.failureSignUpHandler?(error)
            }
        }
    }
}
