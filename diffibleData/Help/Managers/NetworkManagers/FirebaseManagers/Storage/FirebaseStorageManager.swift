//
//  FireBaseStorageHelp.swift
//  diffibleData
//
//  Created by Arman Davidoff on 27.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation
import FirebaseStorage
import UIKit

//MARK: Upload
class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    private let storage: Storage = {
        let store = Storage.storage()
        return store
    }()
    private var myStorage: StorageReference {
        return storage.reference()
    }
    
    func uploadAudio(audioData: Data, complition: @escaping (Result<String,Error>) -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        let audioName = [idString,UUID().uuidString,Date().description,".m4a"].joined()
        audioRef.child(audioName).putData(audioData, metadata: metadata) { [weak self] (metadata, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            self?.audioRef.child(audioName).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    complition(.failure(error!))
                    return
                }
                complition(.success(downloadURL.absoluteString))
            }
        }
    }
    
    func uploadChatImage(photo: UIImage, complition: @escaping (Result<String,Error>) -> Void) {
        guard let scaledPhoto = photo.scaledToSafeUploadSize else { return }
        guard let photoData = scaledPhoto.jpegData(compressionQuality: 0.4)  else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let photoName = [idString,UUID().uuidString,Date().description].joined()
        
        chatsImagesRef.child(photoName).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            self.chatsImagesRef.child(photoName).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    complition(.failure(error!))
                    return
                }
                complition(.success(downloadURL.absoluteString))
            }
        }
    }
    
    func uploadAvatarImage(image:UIImage,complition: @escaping (Result<URL,Error>) -> Void) {
        guard let scaledImage = image.scaledToSafeUploadSize else { return }
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.4)  else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        avatarRef.child(idString).putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            self.avatarRef.child(self.idString).downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                complition(.success(downloadURL))
            }
        }
    }
    
    func uploadPostImage(image:UIImage,complition: @escaping (Result<String,Error>) -> Void) {
        guard let scaledImage = image.scaledToSafeUploadSize else { return }
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.4)  else { return }
        let metadata = StorageMetadata()
        let imageName = UUID().uuidString
        metadata.contentType = "image/jpeg"
        postsImagesRef.child(imageName).putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            self.postsImagesRef.child(imageName).downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                complition(.success(downloadURL.absoluteString))
            }
        }
    }
}

//MARK: References
private extension FirebaseStorageManager {
    
    var avatarRef : StorageReference {
        myStorage.child("Avatars")
    }
    
    var chatsImagesRef: StorageReference {
        myStorage.child("Chats")
    }
    
    var postsImagesRef: StorageReference {
        myStorage.child("Posts")
    }
    
    var audioRef: StorageReference {
        myStorage.child("audio")
    }
    
    var idString : String {
        return Auth.auth().currentUser!.uid
    }
}

//MARK: Downloading
extension FirebaseStorageManager {
    
    func downloadData(url:URL,complition: @escaping (Result<Data ,Error>) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1*1024*1024)
        ref.getData(maxSize: megaByte) { [weak self] (data, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let data = data else { return }
            self?.deleteDataFrom(url: url)
            complition(.success(data))
        }
    }
    
    func deleteDataFrom(url: URL) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        ref.delete { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
}

