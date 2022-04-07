//
//  SignUpViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation
import FirebaseAuth

class SignUpViewModel {
    
    var successSignUpHandler: ((User) -> ())?
    var failureSignUpHandler: ((Error) -> ())?
    private let checker = Validator()
    private var authManager: FirebaseAuthManager {
        authManagers.authManager
    }
    var authManagers: AuthManagersContainerProtocol
    
    init(authManagers: AuthManagersContainerProtocol) {
        self.authManagers = authManagers
    }
    
    func register(email: String?, password: String?, confirmPassword: String?) {
        guard checker.checkFilledSignUp(email: email, password: password, comformPassword: confirmPassword) else {
            failureSignUpHandler?(AuthError.notFilled)
            return
        }
        guard checker.mailCorrectForm(email: email!) else {
            failureSignUpHandler?(AuthError.incorrectMail)
            return
        }
        guard checker.passwordsEquel(password: password!, comformPassword: confirmPassword!) else {
            failureSignUpHandler?(AuthError.comformPassword)
            return
        }
        authManager.register(email: email!, password: password!) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.successSignUpHandler?(user)
            case .failure(let error):
                self.failureSignUpHandler?(error)
            }
        }
    }
}
