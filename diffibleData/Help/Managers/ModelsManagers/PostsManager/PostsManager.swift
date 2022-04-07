//
//  PostsManager.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PostsManager {
    
    private var currentUser: MUser {
        return managerModel.currentUser
    }
    var filterUser: MUser?
    private var posts = [MPost]()
    private var filterPosts = [MPost]()
    private var firestoreManager: FirestoreManager {
        return managerModel.firestoreManager
    }
    var managerModel: ManagersModelContainerProtocol
    
    var allPosts: [MPost] {
        return posts.filter { !$0.owner!.removed }
    }
    
    var filteredPosts: [MPost] {
        return filterPosts
    }
    
    init(managerModel: ManagersModelContainerProtocol) {
        self.managerModel = managerModel
    }
    
    func createPost(text: String, image: UIImage?, imageSize: CGSize?) {
        let post = MPost(textContent: text)
        if let image = image, let imageSize = imageSize {
            FirebaseStorageManager.shared.uploadPostImage(image: image) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let url):
                    post.urlImage = url
                    post.imageSize = imageSize
                    self.createPost(post: post)
                case .failure(let error):
                    self.sendNotificationForCreatePost(type: .failure, error: error)
                }
            }
        }
        else {
            createPost(post: post)
        }
    }
    
    func getFilteredPosts(user: MUser) {
        filterUser = user
        firestoreManager.getUserFirstPosts(user: user) { [weak self] (result) in
            switch result {
            case .success(let posts):
                self?.postsConfigurate(posts: posts, filter: true)
            case .failure(let error):
                self?.sendNotificationForPosts(type: .error, info: nil, error: error)
            }
        }
    }
    
    func getFilteredNextPosts(user: MUser) {
        filterUser = user
        firestoreManager.getUserNextPosts(user: user) { [weak self] (result) in
            switch result {
            case .success(let posts):
                if posts.isEmpty {
                    self?.sendNotificationForPosts(type: .updateNextPosts, info: "Постов больше нет")
                    return
                }
                self?.postsConfigurate(posts: posts, filter: true, next: true)
            case .failure(let error):
                self?.sendNotificationForPosts(type: .error, info: nil, error: error)
            }
        }
    }
    
    func getAllPosts() {
        firestoreManager.getAllFirstPosts { [weak self] (result) in
            switch result {
            case .success(let posts):
                self?.postsConfigurate(posts: posts, filter: false)
            case .failure(let error):
                self?.sendNotificationForPosts(type: .error, info: nil, error: error)
            }
        }
    }
    
    func getNextPosts() {
        self.firestoreManager.getAllNextPosts { [weak self] (result) in
            switch result {
            case .success(let posts):
                if posts.isEmpty {
                    self?.sendNotificationForPosts(type: .updateNextPosts, info: "Постов больше нет")
                    return
                }
                self?.postsConfigurate(posts: posts, filter: false, next: true)
            case .failure(let error):
                self?.sendNotificationForPosts(type: .error, info: nil, error: error)
            }
        }
    }
    
    func deletePost(post: MPost) {
        deletePostFromServer(post: post)
    }
    
    func likePost(post: MPost) {
        if post.likedByMe {
            guard let index = post.likersIds.firstIndex(of: currentUser.id!) else { return }
            post.likersIds.remove(at: index)
            firestoreManager.unlikePost(post: post)
        } else {
            post.likersIds.append(currentUser.id!)
            firestoreManager.likePost(post: post)
        }
        post.likedByMe.toggle()
    }
}

//MARK: Notifications sending
private extension PostsManager {
    
    func sendNotificationForPosts(type: PostsViewModel.NotificationName, info: String? = nil, error: Error? = nil) {
        switch type {
        case .error:
            guard  let error = error else { return }
            NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: ["error": error])
        default:
            if let info = info {
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil, userInfo: ["info": info])
            } else {
                NotificationCenter.default.post(name: type.NSNotificationName, object: nil)
            }
        }
    }
    
    func sendNotificationForCreatePost(type: PostCreateViewModel.NotificationName, error: Error? = nil) {
        if let error = error {
            NotificationCenter.default.post(name: type.NSNotificationName, object: nil,userInfo: ["error": error])
        } else {
            NotificationCenter.default.post(name: type.NSNotificationName, object: nil)
        }
    }
}

//MARK: Help Methods
private extension PostsManager {
    
    func deletePostFromServer(post: MPost) {
        firestoreManager.deletePost(post: post)
    }
    
    func createPost(post: MPost) {
        firestoreManager.createPost(post: post) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success():
                self.sendNotificationForCreatePost(type: .success)
                self.sendNotificationForPosts(type: .updatePostsAfterCreate)
            case .failure(let error):
                self.sendNotificationForCreatePost(type: .failure, error: error)
            }
        }
    }
    
    func postsConfigurate(posts: [MPost], filter: Bool, next: Bool = false) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            posts.forEach { if $0.frames == nil { $0.framesCalculate() } }
            DispatchQueue.main.async {
                posts.forEach { $0.currentUserOwner = $0.owner?.id == self?.currentUser.id! }
                if filter {
                    if next {
                        self?.filterPosts.append(contentsOf: posts)
                        self?.sendNotificationForPosts(type: .updateFilteredNextPosts)
                    } else {
                        self?.filterPosts = posts
                        self?.sendNotificationForPosts(type: .updateFilterPosts)
                    }
                } else {
                    if next {
                        self?.posts.append(contentsOf: posts)
                        self?.sendNotificationForPosts(type: .updateNextPosts)
                    }
                    else {
                        self?.posts = posts
                        self?.sendNotificationForPosts(type: .updatePosts)
                    }
                }
            }
        }
    }
}
