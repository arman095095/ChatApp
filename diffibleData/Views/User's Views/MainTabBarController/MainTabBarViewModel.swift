//
//  MainTabBarViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 01.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

class MainTabBarViewModel {
    
    let peopleTitle = "Люди"
    let communicationTitle = "Чаты"
    let postsTitle = "Посты"
    let profileTitle = "Профиль"
    private let imageConfig = UIImage.SymbolConfiguration(weight: .bold)
    let atributesFont = [NSAttributedString.Key.font: UIFont.avenir13()]
    var updatedBadge = BehaviorRelay<Bool>(value: true)
    var sendingError = BehaviorRelay<Error?>(value: nil)
    private var chatManager: ChatsManager {
        return managers.chatsManager
    }
    var managers: ProfileManagersContainerProtocol
    
    init(managers: ProfileManagersContainerProtocol) {
        self.managers = managers
        initObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    var badgeValueForChats: String? {
        let unlookedChatsCount = chatManager.chatsWithNewMessages.count
        guard unlookedChatsCount != 0 else { return nil }
        return "\(unlookedChatsCount)"
    }
    
    var peopleImage: UIImage {
        return UIImage(systemName: "person.2",withConfiguration: imageConfig)!
    }
    
    var communicationImage: UIImage {
        UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: imageConfig)!
    }
    
    var postsImage: UIImage {
        return UIImage(systemName: "list.dash",withConfiguration: imageConfig)!
    }
    
    var profileImage: UIImage {
        return UIImage(systemName: "person.crop.circle.fill",withConfiguration: imageConfig)!
    }
}

//MARK: Update Badges
private extension MainTabBarViewModel {
    
    @objc func updateChatsBadge() {
        updatedBadge.accept(true)
    }
    
    @objc func handlingError(notification: Notification) {
        guard let error = notification.userInfo?["error"] as? Error else { return }
        sendingError.accept(error)
    }
}

//MARK: Observers
extension MainTabBarViewModel {
    
    enum NotificationName: String, CaseIterable {
        
        case updateChatsBadge
        case error
        
        var userInfoKey: String? {
            return self.rawValue
        }
        
        var NSNotificationName: NSNotification.Name {
            return NSNotification.Name(self.rawValue)
        }
    }
    
    private func initObservers() {
        for name in NotificationName.allCases {
            switch name {
            case .updateChatsBadge:
                NotificationCenter.default.addObserver(self, selector: #selector(updateChatsBadge), name: name.NSNotificationName, object: nil)
            case .error:
                NotificationCenter.default.addObserver(self, selector: #selector(handlingError(notification:)), name: name.NSNotificationName, object: nil)
            }
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
