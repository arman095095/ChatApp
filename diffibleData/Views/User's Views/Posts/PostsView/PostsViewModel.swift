//
//  PostsViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import RxCocoa
import RxRelay
import RxSwift

class PostsViewModel {
    
    private var currentUser: MUser {
        return managers.currentUser
    }
    var filterUser: MUser?
    var posts = [MPost]()
    var updatedPosts = BehaviorRelay<Bool>.init(value: false)
    var updatedNextPosts = BehaviorRelay<(Bool?, String?)>.init(value: (nil,nil))
    var sendingError = BehaviorRelay<Error?>.init(value: nil)
    
    private var postsManager: PostsManager {
        return managers.postsManager
    }
    
    var managers: ProfileManagersContainerProtocol
    
    init(filterUser: MUser?, managers: ProfileManagersContainerProtocol) {
        self.managers = managers
        self.filterUser = filterUser
        initObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    var tabBarHidden: Bool {
        return !allPosts
    }
    
    func getPosts() {
        if allPosts {
            postsManager.getAllPosts()
        } else {
            postsManager.getFilteredPosts(user: filterUser!)
        }
    }
    
    func loadMore() {
        if allPosts {
            allowMoreLoad = false
            postsManager.getNextPosts()
        } else {
            allowMoreLoad = false
            postsManager.getFilteredNextPosts(user: filterUser!)
        }
    }
    
    var postsCountOverLimit: Bool {
        return posts.count >= LimitsConstants.posts
    }
    var allowMoreLoad: Bool = true
    
    var title: String {
        if allPosts { return "Все посты"}
        if yourPosts { return "Ваши посты" }
        return "Посты \(filterUser!.userName)"
    }
    
    var infoTitleText: String {
        if !InternetConnectionManager.isConnectedToNetwork() { return "Проверьте Ваше интернет соединение"}
        if allPosts { return "Постов пока нет" }
        else if yourPosts { return "Вы не добавили ниодного поста" }
        else { return "У этого пользователя пока нет постов" }
    }
    
    var infoTitleHeight: CGFloat {
        if posts.isEmpty { return 250 }
        else { return 0 }
    }
    
    func deletePost(post: MPost) {
        guard let deletedPostIndex = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts.remove(at: deletedPostIndex)
        postsManager.deletePost(post: post)
    }
    
    var postsTitleHeight: CGFloat {
        if allPosts { return PostCellConstants.titleViewHeight }
        if yourPosts { return PostCellConstants.titleViewHeight }
        return 0
    }
    
    func showFullText(at indexPath: IndexPath) -> MPost {
        let post = posts[indexPath.row]
        post.showedFullText = true
        return post
    }
    
    func post(at indexPath: IndexPath) -> MPost {
        return posts[indexPath.row]
    }
    
    func likePost(at indexPath: IndexPath) {
        let currentPost = post(at: indexPath)
        postsManager.likePost(post: currentPost)
    }
    
    func postOwner(at indexPath: IndexPath?) -> MUser? {
        guard let indexPath = indexPath else { return nil }
        let selectPost = post(at: indexPath)
        if selectPost.userID == currentUser.id {
            return nil
        }
        return selectPost.owner!
    }
    
    func rowHeight(for indexPath: IndexPath) -> CGFloat {
        return posts[indexPath.row].height
    }
    
}

//MARK: Update
private extension PostsViewModel {
    
    @objc func updatePostsAfterCreate() {
        if allPosts {
            postsManager.getAllPosts()
        } else if yourPosts {
            postsManager.getFilteredPosts(user: currentUser)
        }
    }
    
    @objc func updateNextPosts(notification: Notification) {
        if let info = notification.userInfo?["info"] as? String {
            updatedNextPosts.accept((false, info))
        } else {
            guard allPosts else { return }
            posts = postsManager.allPosts
            updatedNextPosts.accept((true, nil))
        }
    }
    
    @objc func updatePosts() {
        guard allPosts else { return }
        posts = postsManager.allPosts
        updatedPosts.accept(true)
    }
    
    @objc func updateFilterPosts() {
        guard !allPosts else { return }
        guard let user = postsManager.filterUser else { return }
        if filterUser!.id == user.id {
            posts = postsManager.filteredPosts
            updatedPosts.accept(true)
        }
    }
    
    @objc func updateFilteredNextPosts() {
        guard !allPosts else { return }
        guard let user = postsManager.filterUser else { return }
        if filterUser!.id == user.id {
            posts = postsManager.filteredPosts
            updatedNextPosts.accept((true, nil))
        }
    }
    
    @objc func handlingError(notification: Notification) {
        guard let error = notification.userInfo?["error"] as? Error else { return }
        sendingError.accept(error)
    }
}

//MARK: Observer
extension PostsViewModel {
    
    enum NotificationName: String, CaseIterable {
        
        case updatePosts
        case updateNextPosts
        case updateFilterPosts
        case updateFilteredNextPosts
        case updatePostsAfterCreate
        case error
        
        var NSNotificationName: NSNotification.Name {
            return NSNotification.Name(self.rawValue)
        }
    }
    
    private func initObservers() {
        for name in NotificationName.allCases {
            switch name {
            case .updatePosts:
                NotificationCenter.default.addObserver(self, selector: #selector(updatePosts), name: name.NSNotificationName, object: nil)
            case .updateFilterPosts:
                NotificationCenter.default.addObserver(self, selector: #selector(updateFilterPosts), name: name.NSNotificationName, object: nil)
            case .updatePostsAfterCreate:
                NotificationCenter.default.addObserver(self, selector: #selector(updatePostsAfterCreate), name: name.NSNotificationName, object: nil)
            case .updateNextPosts:
                NotificationCenter.default.addObserver(self, selector: #selector(updateNextPosts), name: name.NSNotificationName, object: nil)
            case .updateFilteredNextPosts:
                NotificationCenter.default.addObserver(self, selector: #selector(updateFilteredNextPosts), name: name.NSNotificationName, object: nil)
            case .error:
                NotificationCenter.default.addObserver(self, selector: #selector(handlingError), name: name.NSNotificationName, object: nil)
            }
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: Help

extension PostsViewModel {
    
    var yourPosts: Bool {
        return currentUser.id == filterUser!.id
    }
    
    var allPosts: Bool {
        return filterUser == nil
    }
}
