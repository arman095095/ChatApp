//
//  FirestoreManager + Extension Chats.swift
//  diffibleData
//
//  Created by Arman Davidoff on 16.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation
import FirebaseFirestore
import UIKit

//MARK: Chats Extension (Send Data)
extension FirestoreManager {
    
    func sendLookedMessages(chat: MChat, complition: @escaping (Result<Void,Error>) -> Void) {
        usersRef.document(chat.friendID!).collection("notifications").document(chat.ownerID!).setData(["looked": chat.ownerID!]) { (error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            complition(.success(()))
        }
    }
    
    func sendMessage(message: MMessage, complition: @escaping (Result<Void,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
        }
        if let imageData = message.imageData, let image = UIImage(data: imageData) {
            sendPhotoMessage(message: message, image: image, complition: complition)
        } else if let audioLocalURL = message.audioURL {
            let url = FileManager.getDocumentsDirectory().appendingPathComponent(audioLocalURL)
            guard let audioData = try? Data(contentsOf: url) else {
                complition(.failure(NSError(domain: "Error", code: 10, userInfo: nil)))
                return
            }
            sendAudioMessage(message: message, audioData: audioData, complition: complition)
        } else {
            sendPreparedMessage(message: message, complition: complition)
        }
    }
    
    func sendChatActive(chat: MChat, complition: @escaping (Result<Void,Error>) -> Void) {
        let ref = db.collection(["users", chat.friendID!, "activeChat"].joined(separator: "/"))
        ref.document(chat.id).setData(["senderID": chat.ownerID!]) { error in
            if let error = error {
                complition(.failure(error))
                return
            }
            complition(.success(()))
        }
    }
    
    func checkTypingStatus(chat: MChat, complition: @escaping (Bool) -> Void) {
        usersRef.document(currentUserID).collection("typing").document(chat.friendID!).getDocument { (documentSnapshot, error) in
            if let _ = error {
                complition(false)
                return
            }
            guard let doc = documentSnapshot else {
                complition(false)
                return
            }
            guard let _ = doc.data()?["id"] as? String else {
                complition(false)
                return
            }
            complition(true)
        }
    }
    
    func sendTyping(chat: MChat, complition: @escaping (Result<Void,Error>) -> Void) {
        usersRef.document(chat.friendID!).collection("typing").document(currentUserID).setData(["id": currentUserID]) { (error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            complition(.success(()))
        }
    }
    
    func sendFinishTyping(chat: MChat, complition: @escaping (Result<Void,Error>) -> Void) {
        usersRef.document(chat.friendID!).collection("typing").document(currentUserID).delete { (error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            complition(.success(()))
        }
    }
}

//MARK: Help
private extension FirestoreManager {
    
    func sendAudioMessage(message: MMessage, audioData: Data, complition: @escaping (Result<Void,Error>) -> Void) {
        FirebaseStorageManager.shared.uploadAudio(audioData: audioData) { [weak self] (result) in
            switch result {
            case .success(let url):
                message.audioURL = url
                self?.sendPreparedMessage(message: message, complition: complition)
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    func sendPhotoMessage(message: MMessage, image: UIImage, complition: @escaping (Result<Void,Error>) -> Void) {
        FirebaseStorageManager.shared.uploadChatImage(photo: image) { [weak self] (result) in
            switch result {
            case .success(let url):
                message.photoURL = url
                self?.sendPreparedMessage(message: message, complition: complition)
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    func sendPreparedMessage(message: MMessage, complition: @escaping (Result<Void,Error>) -> Void) {
        let ref = db.collection(["users",message.adressID!, "messages"].joined(separator: "/"))
        ref.document(message.messageId).setData(message.convertModelToDictionary()) { (error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            complition(.success(()))
        }
    }
}
