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

protocol RootNavigationModuleOutput: AnyObject {
    
}

protocol RootNavigationModuleInput: AnyObject {
    
}

protocol RootNavigationViewOutput: AnyObject {
    func viewDidLoad()
}

final class RootNavigationPresenter {
    
    weak var view: RootNavigationViewInput?
    weak var output: RootNavigationModuleOutput?
    private let router: RootNavigationRouterInput
    private let interactor: RootNavigationInteractorInput
    private let quickAccessManager: QuickAccessManagerProtocol
    private let container: Container
    
    init(router: RootNavigationRouterInput,
         interactor: RootNavigationInteractorInput,
         quickAccessManager: QuickAccessManagerProtocol,
         container: Container) {
        self.router = router
        self.interactor = interactor
        self.quickAccessManager = quickAccessManager
        self.container = container
    }
}

extension RootNavigationPresenter: RootNavigationViewOutput {
    func viewDidLoad() {
        guard let _ = quickAccessManager.userID,
              quickAccessManager.userRemembered else {
            router.openAuthorizationModule(output: self, container: container)
            return
        }
        router.openAuthorizedZone(output: self, container: container)
    }
}

extension RootNavigationPresenter: RootNavigationInteractorOutput {
    
}

extension RootNavigationPresenter: RootNavigationModuleInput {
    
}

extension RootNavigationPresenter: AuthorizedZoneModuleOutput {
    func openAuthorization() {
        router.openAuthorizationModule(output: self, container: container)
    }
}

extension RootNavigationPresenter: AuthorizationModuleOutput {

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

extension RootNavigationPresenter: AccountModuleOutput {
    
}
