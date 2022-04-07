//
//  FirebaseManager + Extension.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore

//MARK: Posts Extension
extension FirestoreManager {
    
    func createPost(post: MPost, complition: @escaping (Result<Void,Error>) -> Void) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
            return
        }
        post.userID = currentUserID
        postsRef.document(post.id).setData(post.convertModelToDictionary()) { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                complition(.failure(error))
                return
            }
            self.usersRef.document(self.currentUserID).collection("posts").document(post.id).setData(post.convertModelToDictionary(), completion: { (error) in
                if let error = error {
                    complition(.failure(error))
                    return
                }
                complition(.success(()))
            })
        }
    }
    
    private func getPostLikers(post: MPost, complition: @escaping (Result<[String],Error>) -> ()) {
        postsRef.document(post.id).collection("likers").getDocuments { (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else {
                complition(.success([]))
                return
            }
            var ids = [String]()
            querySnapshot.documents.forEach {
                if let id = $0.data()["id"] as? String {
                    ids.append(id)
                }
            }
            complition(.success(ids))
        }
    }
    
    func getUserFirstPosts(user: MUser, complition: @escaping (Result<[MPost],Error>) -> ()) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
        }
        var posts = [MPost]()
        if user.removed {
            complition(.success(posts))
            return
        }
        usersRef.document(user.id!).collection("posts").order(by: "date", descending: true).limit(to: LimitsConstants.posts).getDocuments() { (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            guard !querySnapshot.documents.isEmpty else  {
                complition(.success([]))
                return
            }
            var i = 0
            let count = querySnapshot.documents.count
            querySnapshot.documents.forEach { (documentSnapshot) in
                i += 1
                if i == count { self.lastPostUser = documentSnapshot }
                if let post = MPost(documentSnapshot: documentSnapshot) {
                    post.owner = user
                    posts.append(post)
                }
            }
            let postsCount = posts.count
            var index = 0
            posts.forEach { post in
                self.getPostLikers(post: post, complition: { (result) in
                    index += 1
                    switch result {
                    case .success(let ids):
                        post.likersIds = ids
                        post.likedByMe = ids.contains(self.currentUserID)
                    case .failure(let error):
                        complition(.failure(error))
                    }
                    if index == postsCount {
                        complition(.success(posts))
                    }
                })
            }
        }
    }
    
    func getUserPostsCount(user: MUser, complition: @escaping (Result<Int,Error>) -> ()) {
        if user.removed {
            complition(.success(0))
            return
        }
        usersRef.document(user.id!).collection("posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            let count = querySnapshot.count
            complition(.success(count))
        }
    }
    
    func getUserNextPosts(user: MUser, complition: @escaping (Result<[MPost],Error>) -> ()) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
        }
        guard let last = lastPostUser, let postOwnerID = MPost(documentSnapshot: last)?.userID, postOwnerID == user.id else { return }
        var posts = [MPost]()
        if user.removed {
            complition(.success(posts))
            return
        }
        usersRef.document(user.id!).collection("posts").order(by: "date", descending: true).start(afterDocument: last).limit(to: LimitsConstants.posts).getDocuments() { (querySnapshot, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            guard !querySnapshot.documents.isEmpty else  {
                complition(.success([]))
                return
            }
            var i = 0
            let count = querySnapshot.documents.count
            querySnapshot.documents.forEach { (documentSnapshot) in
                i += 1
                if i == count { self.lastPostUser = documentSnapshot }
                if let post = MPost(documentSnapshot: documentSnapshot) {
                    post.owner = user
                    posts.append(post)
                }
            }
            
            let postsCount = posts.count
            var index = 0
            posts.forEach { post in
                self.getPostLikers(post: post, complition: { (result) in
                    index += 1
                    switch result {
                    case .success(let ids):
                        post.likersIds = ids
                        post.likedByMe = ids.contains(self.currentUserID)
                    case .failure(let error):
                        complition(.failure(error))
                    }
                    if index == postsCount {
                        complition(.success(posts))
                    }
                })
            }
        }
    }
    
    func getAllNextPosts(complition: @escaping (Result<[MPost],Error>) -> ()) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
        }
        guard let lastDocument = lastPostOfAll else { return }
        var posts = [MPost]()
        postsRef.order(by: "date", descending: true).start(afterDocument: lastDocument).limit(to: LimitsConstants.posts).getDocuments() { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            guard !querySnapshot.documents.isEmpty else  {
                complition(.success([]))
                return
            }
            
            var dict: [String: [MPost]] = [:]
            querySnapshot.documents.forEach { (documentSnapshot) in
                if let post = MPost(documentSnapshot: documentSnapshot) {
                    if let postsArr = dict[post.userID!] {
                        var new = postsArr
                        new.append(post)
                        dict[post.userID!] = new
                    } else {
                        dict[post.userID!] = [post]
                    }
                    posts.append(post)
                }
                if querySnapshot.documents.last == documentSnapshot {
                    self.lastPostOfAll = documentSnapshot
                }
            }
            
            let count = dict.keys.count
            var index = 0
            dict.keys.forEach { userid in
                self.getUserProfileForShow(userID: userid, complition: { (result) in
                    switch result {
                    case .success(let user):
                        index += 1
                        dict[userid]?.forEach { post in
                            post.owner = user
                        }
                        if index == count {
                            let postsCount = posts.count
                            var i = 0
                            posts.forEach { post in
                                self.getPostLikers(post: post, complition: { (result) in
                                    i += 1
                                    switch result {
                                    case .success(let ids):
                                        post.likersIds = ids
                                        post.likedByMe = ids.contains(self.currentUserID)
                                    case .failure(let error):
                                        complition(.failure(error))
                                    }
                                    if i == postsCount {
                                        complition(.success(posts))
                                    }
                                })
                            }
                        }
                    case .failure(let error):
                        complition(.failure(error))
                    }
                })
            }
        }
    }
    
    func getAllFirstPosts(complition: @escaping (Result<[MPost],Error>) -> ()) {
        if !InternetConnectionManager.isConnectedToNetwork() {
            complition(.failure(ConnectionError.noInternet))
        }
        var posts = [MPost]()
        postsRef.order(by: "date", descending: true).limit(to: LimitsConstants.posts).getDocuments() { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                complition(.failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            guard !querySnapshot.documents.isEmpty else  {
                complition(.success([]))
                return
            }
            
            var dict: [String: [MPost]] = [:]
            querySnapshot.documents.forEach { (documentSnapshot) in
                if let post = MPost(documentSnapshot: documentSnapshot) {
                    if let postsArr = dict[post.userID!] {
                        var new = postsArr
                        new.append(post)
                        dict[post.userID!] = new
                    } else {
                        dict[post.userID!] = [post]
                    }
                    posts.append(post)
                }
                if querySnapshot.documents.last == documentSnapshot {
                    self.lastPostOfAll = documentSnapshot
                }
            }
            
            let count = dict.keys.count
            var index = 0
            
            dict.keys.forEach { userid in
                self.getUserProfileForShow(userID: userid, complition: { (result) in
                    switch result {
                    case .success(let user):
                        index += 1
                        dict[userid]?.forEach { post in
                            post.owner = user
                        }
                        if index == count {
                            let postsCount = posts.count
                            var i = 0
                            posts.forEach { post in
                                self.getPostLikers(post: post, complition: { (result) in
                                    i += 1
                                    switch result {
                                    case .success(let ids):
                                        post.likersIds = ids
                                        post.likedByMe = ids.contains(self.currentUserID)
                                    case .failure(let error):
                                        complition(.failure(error))
                                    }
                                    if i == postsCount {
                                        complition(.success(posts))
                                    }
                                })
                            }
                        }
                    case .failure(let error):
                        complition(.failure(error))
                    }
                })
            }
            
        }
    }
    
    func deletePost(post: MPost) {
        postsRef.document(post.id).collection("likers").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let _ = error {
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            querySnapshot.documents.forEach {
                self.postsRef.document(post.id).collection("likers").document($0.documentID).delete()
            }
            self.postsRef.document(post.id).delete { (error) in
                if let _ = error {
                    return
                }
                self.usersRef.document(self.currentUserID).collection("posts").document(post.id).collection("likers").getDocuments { [weak self] (querySnapshot, error) in
                    guard let self = self else { return }
                    if let _ = error {
                        return
                    }
                    guard let querySnapshot = querySnapshot else { return }
                    querySnapshot.documents.forEach {
                        self.usersRef.document(self.currentUserID).collection("posts").document(post.id).collection("likers").document($0.documentID).delete()
                    }
                    self.usersRef.document(self.currentUserID).collection("posts").document(post.id).delete { (error) in
                        if let _ = error {
                            return
                        }
                    }
                }
            }
        }
    }
    
    func likePost(post: MPost) {
        postsRef.document(post.id).collection("likers").document(currentUserID).setData(["id": currentUserID])
        usersRef.document(post.owner!.id!).collection("posts").document(post.id).collection("likers").document(self.currentUserID).setData(["id": self.currentUserID])
    }
    
    func unlikePost(post: MPost) {
        postsRef.document(post.id).collection("likers").document(currentUserID).delete()
        usersRef.document(post.owner!.id!).collection("posts").document(post.id).collection("likers").document(self.currentUserID).delete()
    }
}
