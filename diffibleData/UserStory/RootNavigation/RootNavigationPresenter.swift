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
import Profile

public protocol RootNavigationModuleOutput: AnyObject {
    
}

public protocol RootNavigationModuleInput: AnyObject {
    
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
        configure()
    }
}

private extension RootNavigationPresenter {
    func configure() {
        guard let accountID = quickAccessManager.userID else {
            AuthorizationUserStoryAssembly.assemble(container: container)
            router.openAuthorizationModule(output: self, container: container)
            return
        }
        AuthorizedZoneUserStoryAssembly.assemble(container: container,
                                                 context: .afterLaunch(accountID: accountID))
        router.openAuthorizedZone(output: self, container: container)
    }
}

extension RootNavigationPresenter: RootNavigationInteractorOutput {
    
}

extension RootNavigationPresenter: RootNavigationModuleInput {
    
}

extension RootNavigationPresenter: AuthorizationModuleOutput {
    func userAuthorized(userID: String, account: AccountModelProtocol) {
        AuthorizedZoneUserStoryAssembly.assemble(container: container,
                                                 context: .afterAuthorization(accountID: userID,
                                                                              account: account))
        router.openAuthorizedZone(output: self, container: container)
    }
}


extension RootNavigationPresenter: AuthorizedZoneModuleOutput {
    func openAuthorization() {
        router.openAuthorizationModule(output: self, container: container)
    }
}
