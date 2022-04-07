//
//  UsersManager.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore

class UsersManager {
    
    var users = [MUser]()
    private var currentUser: MUser {
        return managerModel.currentUser
    }
    private var blockedListener: ListenerRegistration?
    private var firestoreManager: FirestoreManager {
        managerModel.firestoreManager
    }
    var managerModel: ManagersModelContainerProtocol
    
    init(managerModel: ManagersModelContainerProtocol) {
        self.managerModel = managerModel
        getFirstUsers()
        initListeners()
    }
    
    deinit {
        blockedListener?.remove()
    }
    
    func getFirstUsers() {
        let complition: (Result<[MUser], Error>) -> () = { [weak self] (result) in
            switch result {
            case .success(let users):
                self?.users = users
                self?.usersConfigurate()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        firestoreManager.getFirstUsers(complition: complition)
    }
    
    func getNextUsers() {
        let complition: (Result<[MUser], Error>) -> () = { [weak self] (result) in
            switch result {
            case .success(let users):
                self?.users.append(contentsOf: users)
                self?.usersConfigurate()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        firestoreManager.getNextUsers(complition: complition)
    }
}

//MARK: Help
private extension UsersManager {
    
    func usersConfigurate() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.users.sort(by: { (user1, user2) -> Bool in
                return user1.lastActivity! > user2.lastActivity!
            })
            self?.sendNotificationForUsers(type: .updateUsers, userInfo: nil)
        }
    }
}


//MARK: Listeners
private extension UsersManager {
    
    func initListeners() {
        blockedListener = firestoreManager.blockedListener(ids: currentUser.iamblockedIds, complition: { [weak self] (result) in
            switch result {
            case .success(let ids):
                self?.currentUser.iamblockedIds = ids
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
}

//MARK: Notifications sending
private extension UsersManager {
    
    func sendNotificationForUsers(type: PeopleViewModel.NotificationName, userInfo: Any?) {
        switch type {
        case .updateUsers:
            NotificationCenter.default.post(name: type.NSNotificationName, object: nil)
        case .error:
            if let error = userInfo as? Error {
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil,userInfo: ["error": error])
            }
        }
    }
}
