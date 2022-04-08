//
//  FirestoreManager + Extension Profile.swift
//  diffibleData
//
//  Created by Arman Davidoff on 03.01.2021.
//  Copyright © 2021 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore
import UIKit

//MARK: Profile Settings
extension FirestoreManager {
    
    func removeUserProfile(user: MUser,complition: @escaping (Result<MUser,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
            return
        }
        usersRef.document(currentUserID).updateData(["removed": true],completion: { (error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            complition(.success((user)))
        })
    }
    
    func editUserProfile(editedUser: MUser, photo: UIImage?, imageURL: String? ,complition: @escaping (Result<MUser,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
            return
        }
        if let image = photo {
            FirebaseStorageManager.shared.uploadAvatarImage(image: image) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let url):
                    editedUser.imageUrl = url.absoluteString
                    self.setUser(user: editedUser, complition: complition)
                case .failure(let error):
                    complition(.failure(error))
                }
            }
        } else if let urlString = imageURL {
            editedUser.imageUrl = urlString
            self.setUser(user: editedUser, complition: complition)
        }
    }
    
    private func setUser(user: MUser , complition: @escaping (Result<MUser,Error>) -> Void) {
        self.usersRef.document(self.currentUserID).setData(user.convertModelToDictionary()) { [weak self] (error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            self?.currentUser.updateInfo(with: user)
            complition(.success(user))
        }
    }
}
