//
//  UsersBlocking.swift
//  diffibleData
//
//  Created by Arman Davidoff on 05.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

//MARK: Block Extension
extension FirestoreManager {
    
    func getBlockedUsers(blocked: [String],complition: @escaping (Result<[MUser],Error>) -> Void) {
        var users = [MUser]()
        
        let count = blocked.count
        var index = 0
        if count == index {
            complition(.success([]))
            return
        }
        blocked.forEach { id in
            getUserProfileForShow(userID: id) { (result) in
                index += 1
                switch result {
                case .success(let user):
                    users.append(user)
                case .failure(let error):
                    complition(.failure(error))
                }
                if index == count {
                    complition(.success(users))
                }
            }
        }
    }
    
    func blockUser(user: MUser, complition: @escaping (Result<String,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
            return
        }
        usersRef.document(currentUserID).collection("blocked").document(user.id!).setData(["id": user.id!]) { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                complition(.failure(error))
            }
            self.usersRef.document(user.id!).collection("iamblocked").document(self.currentUserID).setData(["id": self.currentUserID]) { (error) in
                if let error = error {
                    complition(.failure(error))
                    return
                }
                complition(.success(user.id!))
            }
        }
    }
    
    func unblockUser(user: MUser, complition: @escaping (Result<String,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
            return
        }
        usersRef.document(currentUserID).collection("blocked").document(user.id!).delete { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                complition(.failure(error))
                return
            }
            self.usersRef.document(user.id!).collection("iamblocked").document(self.currentUserID).delete { (error) in
                if let error = error {
                    complition(.failure(error))
                    return
                }
                complition(.success(user.id!))
            }
        }
    }
}
