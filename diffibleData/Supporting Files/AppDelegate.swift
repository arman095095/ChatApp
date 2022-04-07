//
//  AppDelegate.swift
//  diffibleData
//
//  Created by Arman Davidoff on 19.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure() //Для конфигурации всего фреймворка
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID //ЭТО ДЛЯ GOOGLE ВХОДА И РЕГИСТРАЦИИ
        return true
    }
    ////
    @available(iOS 9.0, *) ////ЭТО ДЛЯ GOOGLE ВХОДА И РЕГИСТРАЦИИ  отдельная функция
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}

