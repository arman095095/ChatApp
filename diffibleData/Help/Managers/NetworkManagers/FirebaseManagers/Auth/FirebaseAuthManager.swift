//
//  FireBaseAuthHelp.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

//MARK: Auth
class FirebaseAuthManager {
    
    let db: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let base = Firestore.firestore()
        base.settings = settings
        return base
    }()
    
    func register(email: String, password: String, handler: @escaping (Result<User,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            handler(.failure(ConnectionError.noInternet))
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let user = result?.user else { return }
            handler(.success(user))
        }
    }
    
    func login(user:GIDGoogleUser!,error:Error!,complition: @escaping (Result<User,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
            return
        }
        if let error = error {
            complition(.failure(error))
            return
        }
        guard let authentication = user?.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let user = result?.user else { return }
            complition(.success(user))
        }
        
    }
    
    func login(email:String,password:String,handler: @escaping (Result<User,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            handler(.failure(ConnectionError.noInternet))
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                handler(.failure(error))
                return
            }
            guard let user = result?.user else { return }
            handler(.success(user))
        }
    }
    
    static func signOut(complition: @escaping (Error?) -> ()) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition((ConnectionError.noInternet))
            return
        }
        setOffline {
            try? Auth.auth().signOut()
            complition(nil)
        }
    }
}

//MARK: Profile
extension FirebaseAuthManager {
    
    var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    func createUserProfile(identifier: String, username: String, info: String, sex: String, country: String, city: String, birthday: String, userImage: UIImage, complition: @escaping (Result<MUser,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
            return
        }
        let muser = MUser(userName: username, imageName: "default", identifier: identifier , sex: sex, info: info, birthDay: birthday, country: country, city: city)
        
        FirebaseStorageManager.shared.uploadAvatarImage(image: userImage) { [weak self] (result) in //отправляем изо
            guard let self = self else { return }
            switch result {
            case .success(let url):
                muser.imageUrl = url.absoluteString //меняем фейк поле и отправляем полностью данные о профиле
                self.usersRef.document(identifier).setData(muser.convertModelToDictionary()) { (error) in
                    if let error = error {
                        complition(.failure(error))
                        return
                    }
                    complition(.success(muser))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    func getUserProfile(userID: String, complition: @escaping (Result<MUser,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
        }
        usersRef.document(userID).getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            if let error = error  {
                complition(.failure(error))
                return
            }
            if let documentsnapshot = documentSnapshot {
                if let muser = MUser(documentSnapshot: documentsnapshot) {
                    if muser.removed {
                        complition(.failure(GetUserInfoError.profileRemoved(muser: muser)))
                        return
                    }
                    self.getBlockedUsers(id: muser.id!) { (result) in
                        switch result {
                        case .success(let ids):
                            muser.blockedIds = ids
                            self.getIamBlockedUsers(id: muser.id!) { (result) in
                                switch result {
                                case .success(let ids):
                                    muser.iamblockedIds = ids
                                    FirebaseAuthManager.setOnline()
                                    complition(.success(muser))
                                case .failure(let error):
                                    complition(.failure(error))
                                }
                            }
                        case .failure(let error):
                            complition(.failure(error))
                        }
                    }
                }
                else {
                    complition(.failure(GetUserInfoError.convertData)) }
            }
            else {
                complition(.failure(GetUserInfoError.getData)) }
        }
    }
    
    static func setOnline() {
        if let id = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(id).updateData(["online": true])
        }
    }
    
    static func setOffline(complition: @escaping () -> () = { }) {
        
        let ref = Firestore.firestore().collection("users")
        
        if let id = Auth.auth().currentUser?.uid {
            var dict: [String: Any] = ["lastActivity": FieldValue.serverTimestamp()]
            dict["online"] = false
            ref.document(id).updateData(dict,completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                complition()
            })
        }
    }
    
    func recoverUserProfile(user: MUser,complition: @escaping (Result<MUser,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
            return
        }
        usersRef.document(user.id!).updateData(["removed": false], completion: { [weak self] (error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            self?.getUserProfile(userID: user.id!) { (result) in
                switch result {
                case .success(let muser):
                    complition(.success(muser))
                case .failure(let error):
                    complition(.failure(error))
                }
            }
        })
    }
}

//MARK: Help
private extension FirebaseAuthManager {
    
    func getBlockedUsers(id: String, complition: @escaping (Result<[String],Error>) -> Void) {
        var ids: [String] = []
        usersRef.document(id).collection("blocked").getDocuments { (query, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let query = query else { return }
            query.documents.forEach { doc in
                if let id = doc.data()["id"] as? String {
                    ids.append(id)
                }
            }
            complition(.success(ids))
        }
    }
    
    func getIamBlockedUsers(id: String, complition: @escaping (Result<[String],Error>) -> Void) {
        var ids: [String] = []
        usersRef.document(id).collection("iamblocked").getDocuments { (query, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let query = query else { return }
            query.documents.forEach { doc in
                if let id = doc.data()["id"] as? String {
                    ids.append(id)
                }
            }
            complition(.success(ids))
        }
    }
}
