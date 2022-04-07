//
//  UsersListener.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore

//MARK: Users Listener Extension
extension FirestoreManager {
    
    func listenerForUsers(complition: @escaping (Result<[MUser],Error>) -> Void) -> ListenerRegistration? {
        let listener = usersRef.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            var editedUsers = [MUser]()
            
            var count = querySnapshot.documentChanges.count
            var index = 0
            querySnapshot.documentChanges.forEach { query in
                guard query.document.documentID != self.currentUserID, self.currentUser.friendsIds.contains(query.document.documentID) else {
                    count -= 1
                    return
                }
                self.getUserProfileForShow(userID: query.document.documentID) { (result) in
                    index += 1
                    switch result {
                    case .success(let muser):
                        switch query.type {
                        case .modified:
                            editedUsers.append(muser)
                        default:
                            break
                        }
                        if index == count {
                            complition(.success(editedUsers))
                        }
                    case .failure(let error):
                        complition(.failure(error))
                    }
                }
            }
        }
        return listener
    }
    
    func blockedListener(ids: [String],complition: @escaping (Result<[String],Error>) -> Void) -> ListenerRegistration? {
        var newIds = ids
        
        let listener = usersRef.document(currentUserID).collection("iamblocked").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            querySnapshot.documentChanges.forEach {
                guard let id = $0.document.data()["id"] as? String else { return }
                switch $0.type {
                case .added:
                    if newIds.contains(id) { return }
                    newIds.append(id)
                case .modified:
                    break
                case .removed:
                    guard let index = newIds.firstIndex(of: id) else  { return }
                    newIds.remove(at: index)
                }
            }
            complition(.success(newIds))
        }
        return listener
    }
}
