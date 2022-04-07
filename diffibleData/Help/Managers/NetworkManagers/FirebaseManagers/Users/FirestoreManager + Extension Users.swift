//
//  FireBaseDataHelp.swift
//  diffibleData
//
//  Created by Arman Davidoff on 26.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

//MARK: Users
extension FirestoreManager {
    
    func getFirstUsers(complition: @escaping (Result<[MUser],Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
        }
        let query = usersRef.order(by: "lastActivity", descending: true).limit(to: LimitsConstants.users)
        getFirstUsers(query: query, complition: complition)
    }
    
    func getNextUsers(complition: @escaping (Result<[MUser],Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
        }
        let query = usersRef.order(by: "lastActivity", descending: true).limit(to: LimitsConstants.users)
        getNextUsers(query: query, complition: complition)
    }
    
    func getUserProfileForShow(userID: String, complition: @escaping (Result<MUser,Error>) -> ()) {
        usersRef.document(userID).getDocument { [weak self] (documentSnapshot, error) in
            if let error = error  {
                complition(.failure(error))
                return
            }
            guard let documentsnapshot = documentSnapshot else  { return }
            guard let muser = MUser(documentSnapshot: documentsnapshot) else { return }
            self?.getUserPostsCount(user: muser) { (result) in
                switch result {
                case .success(let count):
                    muser.postsCount = count
                    if userID == self?.currentUserID {
                        self?.currentUser.updateInfo(with: muser)
                    }
                    complition(.success(muser))
                case .failure(let error):
                    complition(.failure(error))
                }
            }
        }
    }
}

//MARK: Help
private extension FirestoreManager {
    
    func getFirstUsers(query: Query, complition: @escaping (Result<[MUser],Error>) -> Void) {
        var users = [MUser]()
        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            let count = querySnapshot.documents.count
            var index = 0
            querySnapshot.documents.forEach { doc in
                if querySnapshot.documents.last == doc {
                    self.lastUser = doc
                }
                guard doc.documentID != self.currentUserID else {
                    index += 1
                    if index == count {
                        complition(.success(users))
                    }
                    return
                }
                self.getUserProfileForShow(userID: doc.documentID) { (result) in
                    index += 1
                    switch result {
                    case .success(let muser):
                        users.append(muser)
                    case .failure(let error):
                        complition(.failure(error))
                    }
                    if index == count {
                        complition(.success(users))
                    }
                }
            }
        }
    }
    
    func getNextUsers(query: Query, complition: @escaping (Result<[MUser],Error>) -> Void) {
        guard let lastDocument = lastUser else { return }
        var users = [MUser]()
        query.start(afterDocument: lastDocument).limit(to: LimitsConstants.users).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            let count = querySnapshot.documents.count
            var index = 0
            querySnapshot.documents.forEach { doc in
                if querySnapshot.documents.last == doc {
                    self.lastUser = doc
                }
                guard doc.documentID != self.currentUserID else {
                    index += 1
                    if index == count {
                        complition(.success(users))
                    }
                    return
                }
                self.getUserProfileForShow(userID: doc.documentID) { (result) in
                    index += 1
                    switch result {
                    case .success(let muser):
                        users.append(muser)
                    case .failure(let error):
                        complition(.failure(error))
                    }
                    if index == count {
                        complition(.success(users))
                    }
                }
            }
        }
    }
}


