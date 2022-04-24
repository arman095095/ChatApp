//
//  UserStory.swift
//  diffibleData
//
//  Created by Арман Чархчян on 22.04.2022.
//  Copyright © 2022 Arman Davidoff. All rights reserved.
//

import Foundation
import Module
import Swinject
import Managers

public protocol LaunchRouteMap: AnyObject {
    func rootModule() -> ModuleProtocol
}

public final class LaunchUserStory {
    private let container: Container
    public init(container: Container) {
        self.container = container
    }
}

extension LaunchUserStory: LaunchRouteMap {
    public func rootModule() -> ModuleProtocol {
        guard let quickAccessManager = container.synchronize().resolve(QuickAccessManagerProtocol.self) else { fatalError(ErrorMessage.dependency.localizedDescription) }
        let module = UnauthorizedNavigationAssembly.makeModule(quickAccessManager: quickAccessManager, container: container)
        return module
    }
}

enum ErrorMessage: LocalizedError {
    case dependency
}
