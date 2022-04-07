//
//  ChatsListener.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore

//MARK: Chats Listener Extension
extension FirestoreManager {
    
    func listenerForTyping(complition: @escaping (Result<([String],[String]),Error>) -> Void) -> ListenerRegistration? {
        let ref = db.collection(["users", currentUserID, "typing"].joined(separator: "/"))
        let listener = ref.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            var typingIDs = [String]()
            var finishTypingIDs = [String]()
            querySnapshot.documentChanges.forEach {
                switch $0.type {
                case .added:
                    guard let senderID = $0.document.data()["id"] as? String else { return }
                    typingIDs.append(senderID)
                case .removed:
                    guard let senderID = $0.document.data()["id"] as? String else { return }
                    finishTypingIDs.append(senderID)
                case .modified:
                    break
                }
            }
            complition(.success((typingIDs,finishTypingIDs)))
        }
        return listener
    }
    
    func listenerForChatStatus(complition: @escaping (Result<[(String,String)],Error>) -> Void) -> ListenerRegistration? {
        let ref = db.collection(["users", currentUserID, "activeChat"].joined(separator: "/"))
        let listener = ref.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            var chatIDs = [(String,String)]()
            querySnapshot.documentChanges.forEach {
                switch $0.type {
                case .added:
                    guard let senderID = $0.document.data()["senderID"] as? String else { return }
                    let chatID = $0.document.documentID
                    let ids = (senderID,chatID)
                    chatIDs.append(ids)
                    ref.document(chatID).delete()
                default:
                    break
                }
            }
            complition(.success(chatIDs))
        }
        return listener
    }
}
