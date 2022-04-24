//
//  UnauthorizedNavigationAssembly.swift
//  diffibleData
//
//  Created by Арман Чархчян on 22.04.2022.
//  Copyright (c) 2022 Arman Davidoff. All rights reserved.
//

import UIKit
import Module
import Managers
import Swinject

typealias UnauthorizedNavigationModule = Module<UnauthorizedNavigationModuleInput, UnauthorizedNavigationModuleOutput>

enum UnauthorizedNavigationAssembly {
    static func makeModule(quickAccessManager: QuickAccessManagerProtocol, container: Container) -> UnauthorizedNavigationModule {
        let view = UnauthorizedNavigationController()
        let router = UnauthorizedNavigationRouter()
        let interactor = UnauthorizedNavigationInteractor()
        let presenter = UnauthorizedNavigationPresenter(router: router,
                                                        interactor: interactor,
                                                        quickAccessManager: quickAccessManager,
                                                        container: container)
        view.output = presenter
        interactor.output = presenter
        presenter.view = view
        router.transitionHandler = view
        return UnauthorizedNavigationModule(input: presenter, view: view) {
            presenter.output = $0
        }
    }
}
