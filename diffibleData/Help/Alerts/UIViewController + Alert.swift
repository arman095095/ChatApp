//
//  AlertInViewController.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    
    func createAlert(title: String, message: String, complition: @escaping ( () -> Void ) = { }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            complition()
        } )
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
    }
    
    func createAlertForRecover(error: GetUserInfoError, complitionAccept: @escaping (() -> Void), complitionDeny: @escaping (() -> Void)) {
        let alert = UIAlertController(title: "Не удалось выполнить вход", message: error.localizedDescription, preferredStyle: .alert)
        let recoverAction = UIAlertAction(title: "Восстановить", style: .default, handler: { _ in
            complitionAccept()
        } )
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: { _ in
            complitionDeny()
        } )
        alert.addAction(cancelAction)
        alert.addAction(recoverAction)
        present(alert, animated: true, completion: nil)
    }
}
