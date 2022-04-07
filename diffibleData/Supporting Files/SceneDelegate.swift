//
//  SceneDelegate.swift
//  diffibleData
//
//  Created by Arman Davidoff on 19.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import SwiftUI
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 15, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) { }
        })
        self.window = Builder.shared.mainWindow(scene: windowScene)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        FirebaseAuthManager.setOffline()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        FirebaseAuthManager.setOffline()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        FirebaseAuthManager.setOnline()
    }
}

