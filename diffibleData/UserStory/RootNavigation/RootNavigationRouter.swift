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
import Managers
import Profile

protocol RootNavigationRouterInput: AnyObject {
    func openAuthorizationModule(output: AuthorizationModuleOutput,
                                 container: Container)
    func openAuthorizedZone(context: InputFlowContext,
                            output: AuthorizedZoneModuleOutput,
                            container: Container)
    func openAccountCreationModule(output: AccountModuleOutput,
                                   container: Container)
    func openAccountEditModule(output: AccountModuleOutput,
                               container: Container)
    func openProfileModule(profile: ProfileModelProtocol,
                           container: Container,
                           output: ProfileModuleOutput)
}

final class RootNavigationRouter {
    weak var transitionHandler: UINavigationController?
}

extension RootNavigationRouter: RootNavigationRouterInput {

    func openAuthorizedZone(context: InputFlowContext,
                            output: AuthorizedZoneModuleOutput,
                            container: Container) {
        let module = AuthorizedZoneUserStory(container: container).rootModule(context: context)
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
    
    func openProfileModule(profile: ProfileModelProtocol, container: Container, output: ProfileModuleOutput) {
        let module = ProfileUserStory(container: container).friendAccountModule(profile: profile)
        module.output = output
        transitionHandler?.pushViewController(module.view, animated: true)
    }
}
