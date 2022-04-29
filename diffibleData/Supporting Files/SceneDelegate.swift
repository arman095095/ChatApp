//
//  SceneDelegate.swift
//  diffibleData
//
//  Created by Arman Davidoff on 19.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import Swinject
import Root

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = UIWindow(windowScene: windowScene)
        let container = Container()
        ApplicationAssembly().assemble(container: container)
        let launchModule = LaunchUserStory(container: container).rootModule()
        window?.rootViewController = launchModule.view
        window?.makeKeyAndVisible()
    }
}
