//
//  UnauthorizedNavigationPresenter.swift
//  diffibleData
//
//  Created by Арман Чархчян on 22.04.2022.
//  Copyright (c) 2022 Arman Davidoff. All rights reserved.
//

import UIKit
import Managers
import Swinject
import Authorization
import Settings
import Account
import AuthorizedZone

protocol UnauthorizedNavigationModuleOutput: AnyObject {
    
}

protocol UnauthorizedNavigationModuleInput: AnyObject {
    
}

protocol UnauthorizedNavigationViewOutput: AnyObject {
    func viewDidLoad()
}

final class UnauthorizedNavigationPresenter {
    
    weak var view: UnauthorizedNavigationViewInput?
    weak var output: UnauthorizedNavigationModuleOutput?
    private let router: UnauthorizedNavigationRouterInput
    private let interactor: UnauthorizedNavigationInteractorInput
    private let quickAccessManager: QuickAccessManagerProtocol
    private let container: Container
    
    init(router: UnauthorizedNavigationRouterInput,
         interactor: UnauthorizedNavigationInteractorInput,
         quickAccessManager: QuickAccessManagerProtocol,
         container: Container) {
        self.router = router
        self.interactor = interactor
        self.quickAccessManager = quickAccessManager
        self.container = container
    }
}

extension UnauthorizedNavigationPresenter: UnauthorizedNavigationViewOutput {
    func viewDidLoad() {
        guard let _ = quickAccessManager.userID,
              quickAccessManager.userRemembered else {
            router.openAuthorizationModule(output: self, container: container)
            return
        }
        router.openAuthorizedZone(output: self, container: container)
    }
}

extension UnauthorizedNavigationPresenter: UnauthorizedNavigationInteractorOutput {
    
}

extension UnauthorizedNavigationPresenter: UnauthorizedNavigationModuleInput {
    
}

extension UnauthorizedNavigationPresenter: AuthorizedZoneModuleOutput {
    func openAuthorization() {
        router.openAuthorizationModule(output: self, container: container)
    }
}

extension UnauthorizedNavigationPresenter: AuthorizationModuleOutput {

    func userRegistered() {
        router.openAccountCreationModule(output: self, container: container)
    }
    
    func userAuthorized() {
        router.openAuthorizedZone(output: self, container: container)
    }
    
    func userNotExist() {
        router.openAccountCreationModule(output: self, container: container)
    }
}

extension UnauthorizedNavigationPresenter: AccountModuleOutput {
    
}
