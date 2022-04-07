//
//  FirestoreManager + Extension.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore

//MARK: Messages Listener Extension
extension FirestoreManager {

    func listenerForMessages(complition: @escaping (Result<[MMessage],Error>) -> Void) -> ListenerRegistration? {
        let ref = db.collection(["users", currentUserID, "messages"].joined(separator: "/"))
        
        let listener = ref.addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot, !querySnapshot.isEmpty else { return }
            var newMessages = [MMessage]()
            
            let count = querySnapshot.documentChanges.filter { $0.type == .added }.count
            var index = 0
            
            querySnapshot.documentChanges.forEach { change in
                guard let message = MMessage(queryDocumentSnapshot: change.document) else { return }
                self?.getUserProfileForShow(userID: message.senderID!, complition: { (result) in
                    switch result {
                    case .success(let muser):
                        if change.type == .added {
                            index += 1
                            message.senderUser = muser
                            newMessages.append(message)
                            ref.document(message.id!).delete()
                            if index == count {
                                complition(.success(newMessages))
                            }
                        }
                    case .failure(let error):
                        complition(.failure(error))
                    }
                })
            }
        }
        return listener
    }
    
    func listenerlookedSendedMessages(complition: @escaping (Result<[String],Error>) -> Void) -> ListenerRegistration? {
        let ref = db.collection(["users", currentUserID, "notifications"].joined(separator: "/"))
        
        let listener = ref.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot, !querySnapshot.isEmpty else { return }
            var friendIds = [String]()
            querySnapshot.documentChanges.forEach {
                guard let friendID = $0.document.data()["looked"] as? String else { return }
                switch $0.type {
                case .added:
                    friendIds.append(friendID)
                    ref.document(friendID).delete()
                default:
                    break
                }
            }
            
            complition(.success(friendIds))
        }
        return listener
    }
}


