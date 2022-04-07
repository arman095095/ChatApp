//
//  Extension UIViewController.swift
//  Exschange
//
//  Created by Arman Davidoff on 26.10.2020.
//

import UIKit


extension UIViewController {
    var topBarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) + (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var buttonBarHeight: CGFloat {
        return self.tabBarController?.tabBar.frame.height ?? 0.0
    }
}
