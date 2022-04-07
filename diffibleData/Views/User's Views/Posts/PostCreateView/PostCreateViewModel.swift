//
//  PostCreateViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

class PostCreateViewModel {
    
    private var currentUser: MUser {
        return managers.currentUser
    }
    var imageAvailable = BehaviorRelay<Bool>.init(value: false)
    var textAvailable = BehaviorRelay<Bool>.init(value: false)
    var sendingAvailable = BehaviorRelay<Bool>.init(value: false)
    var sendingSuccess = BehaviorRelay<Bool?>.init(value: nil)
    var sendingError = BehaviorRelay<Error?>.init(value: nil)
    private var postsManager: PostsManager {
        return managers.postsManager
    }
    private let dispose = DisposeBag()
    var imageSize: CGSize?
    var managers: ProfileManagersContainerProtocol
    
    init(managers: ProfileManagersContainerProtocol) {
        self.managers = managers
        setupBinding()
        initObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    private func setupBinding() {
        imageAvailable.asDriver().drive(onNext: { [weak self] availableImage in
            guard let self = self else { return }
            self.sendingAvailable.accept(availableImage || self.textAvailable.value)
        }).disposed(by: dispose)
        
        textAvailable.asDriver().drive(onNext: { [weak self] availableText in
            guard let self = self else { return }
            self.sendingAvailable.accept(availableText || self.imageAvailable.value)
        }).disposed(by: dispose)
    }
    
    func createPost(text: String, image: UIImage?) {
        postsManager.createPost(text: text, image: image, imageSize: imageSize)
    }
}

//MARK: Update
private extension PostCreateViewModel {
    
    @objc func success() {
        currentUser.postsCount += 1
        sendingSuccess.accept(true)
    }
    
    @objc func failure(notification: Notification) {
        sendingSuccess.accept(false)
        guard let error = notification.userInfo?["error"] as? Error else { return }
        sendingError.accept(error)
    }
}

//MARK: Observer
extension PostCreateViewModel {
    
    enum NotificationName {
    
        case success
        case failure
        
        var description: String {
            switch self {
            case .success:
                return "success"
            case .failure:
                return "failure"
            }
        }
        
        var NSNotificationName: NSNotification.Name {
            return NSNotification.Name(self.description)
        }
    }
    
    private func initObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(success), name: NotificationName.success.NSNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failure), name: NotificationName.failure.NSNotificationName, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
