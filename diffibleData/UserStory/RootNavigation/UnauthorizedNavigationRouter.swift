//
//  UnauthorizedNavigationRouter.swift
//  diffibleData
//
//  Created by Арман Чархчян on 22.04.2022.
//  Copyright (c) 2022 Arman Davidoff. All rights reserved.
//

import UIKit
import Authorization
import AuthorizedZone
import Swinject
import Settings
import Account

protocol UnauthorizedNavigationRouterInput: AnyObject {
    func openAuthorizationModule(output: AuthorizationModuleOutput, container: Container)
    func openAuthorizedZone(output: AuthorizedZoneModuleOutput, container: Container)
    func openAccountCreationModule(output: AccountModuleOutput, container: Container)
    func openAccountEditModule(output: AccountModuleOutput, container: Container)
}

final class UnauthorizedNavigationRouter {
    weak var transitionHandler: UINavigationController?
}

extension UnauthorizedNavigationRouter: UnauthorizedNavigationRouterInput {
    func openAuthorizedZone(output: AuthorizedZoneModuleOutput, container: Container) {
        let module = AuthorizedZoneUserStory(container: container).rootModule()
        module.output = output
        transitionHandler?.setViewControllers([module.view], animated: true)
    }
    
    func openAuthorizationModule(output: AuthorizationModuleOutput, container: Container) {
        let module = AuthorizationUserStory(container: container).rootModule()
        module.output = output
        transitionHandler?.setViewControllers([module.view], animated: false)
    }
    
    func openAccountCreationModule(output: AccountModuleOutput, container: Container) {
        let module = AccountUserStory(container: container).createAccountModule()
        module.output = output
        transitionHandler?.pushViewController(module.view, animated: true)
    }
    
    func openAccountEditModule(output: AccountModuleOutput, container: Container) {
        let module = AccountUserStory(container: container).editAccountModule()
        module.output = output
        transitionHandler?.pushViewController(module.view, animated: true)
    }
}
