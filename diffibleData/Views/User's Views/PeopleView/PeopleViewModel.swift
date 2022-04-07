//
//  PeopleViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore
import RxCocoa
import RxSwift
import RxRelay

class PeopleViewModel {
    
    var usersUpdated = BehaviorRelay<Bool>(value: false)
    var sendingError = BehaviorRelay<Error?>(value: nil)
    var people = [MUser]()

    private var currentUser: MUser {
        return managers.currentUser
    }
    private var usersManager: UsersManager {
        return managers.usersManager
    }
    
    var managers: ProfileManagersContainerProtocol
    
    init(managers: ProfileManagersContainerProtocol) {
        self.managers = managers
        initObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    func loadMore() {
        allowMoreLoad = false
        usersManager.getNextUsers()
    }
    
    var usersCountOverLimit: Bool {
        return people.count + 1 >= LimitsConstants.users
    }
    var allowMoreLoad: Bool = true
    
    var current: MUser {
        return currentUser
    }
    
    var title: String {
        return "Люди"
    }
    
    var usersCount: Int {
        return people.count
    }
    
    var userName: String {
        return currentUser.userName
    }
    
    var connected: Bool {
        return InternetConnectionManager.isConnectedToNetwork()
    }
    
    func getUsers() {
        usersManager.getFirstUsers()
    }
}

//MARK: Update Models
private extension PeopleViewModel {
    
    @objc func updateUsers() {
        people = usersManager.users.filter { !$0.removed }
        usersUpdated.accept(true)
    }
    
    @objc func handlingError(notification: Notification) {
        guard let error = notification.userInfo?["error"] as? Error else { return }
        sendingError.accept(error)
    }
    
}

//MARK: Observer
extension PeopleViewModel {
    
    enum NotificationName: String, CaseIterable {
        
        case updateUsers
        case error
        
        var userInfoKey: String {
            return self.rawValue
        }
        
        var NSNotificationName: NSNotification.Name {
            return NSNotification.Name(self.rawValue)
        }
    }
    
    private func initObservers() {
        for name in NotificationName.allCases {
            switch name {
            case .updateUsers:
                NotificationCenter.default.addObserver(self, selector: #selector(updateUsers), name: name.NSNotificationName, object: nil)
            case .error:
                NotificationCenter.default.addObserver(self, selector: #selector(handlingError(notification:)), name: name.NSNotificationName, object: nil)
            }
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
