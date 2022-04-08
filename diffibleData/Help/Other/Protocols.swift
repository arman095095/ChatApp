//
//  ProtocolForDelegateAuth.swift
//  diffibleData
//
//  Created by Arman Davidoff on 26.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import MessageKit

protocol AuthDelegate: AnyObject {
    func goToLoginVC()
    func goToSignInVC()
    func updateViewModel()
}

protocol ChatsOperationsDelegate: AnyObject {
    func removeWaitingChat(chat: MChat)
    func changeChatStatus(chat: MChat)
    func removeActiveChat(chat: MChat)
}

protocol ActiveChatCellType {
    var chat: MChat { get }
    var userName: String { get }
    var imageURL: URL? { get }
    var lastMessageContent: String { get }
    var lastMessageType: MessageKind? { get }
    var lastMessageDate: String { get }
    var newMessagesCount: Int { get }
    var newMessagesEnable: Bool { get }
    var badgeWidth: CGFloat { get }
    var lastMessageMarkedImage: UIImage? { get }
}

protocol PostCellModelType {
    var userName: String { get }
    var postDate: String { get }
    var userImageURL: URL? { get }
    var textContent: String { get }
    var postImageURL: URL? { get }
    var textContentFrame: CGRect { get }
    var postImageFrame: CGRect { get }
    var buttonFrame: CGRect { get }
    var height: CGFloat { get }
    var showedFullText: Bool { set get }
    var currentUserOwnerButtonWidth: CGFloat  { get }
    var online: Bool { get }
    var likesCount: String { get }
    var liked: Bool { get }
    var likesCountAfterLike: String { get }
}

protocol PostCellDelegate: AnyObject {
    func reloadCell(cell: PostCell)
    func presentOwnerAlert(cell: PostCell)
    func openUserProfile(cell: PostCell)
    func likePost(cell: PostCell)
}

protocol CellReloaderProtocol: AnyObject {
    func reloadCell(with chat: MChat)
}

protocol OpenCreatePostViewProtocol: AnyObject {
    func presentCreatePostViewController()
}

protocol MessengerTitleViewDelegate: AnyObject {
    func presentProfile()
}

protocol AreaType {
    var description: String { get }
    func containts(text: String?) -> Bool
}

extension AreaType {
    func containts(text: String?) -> Bool {
        if text == nil || text!.isEmpty || text == "" { return true }
        let text = text!.lowercased()
        let value = description.lowercased()
        if text.count > value.count { return false }
        var fits: Bool!
        for (index,ch) in value.enumerated() {
            let flag = index <= text.count - 1
            if flag {
                let flag2 = ch == text[text.index(text.startIndex, offsetBy: index)]
                fits = flag2
                if !flag2 { break }
            } else {
                fits = true
                break
            }
        }
        return fits
    }
}

protocol AudioManagersContainerProtocol: AnyObject {
    init(recorder: AudioMessageRecorder, player: AudioMessagePlayer)
    var recorder: AudioMessageRecorder { get }
    var player: AudioMessagePlayer { get }
}

protocol ProfileManagersContainerProtocol: AnyObject {
    init(currentUser: MUser, chatsManager: ChatsManager, postsManager: PostsManager, firestoreManager: FirestoreManager, usersManager: UsersManager)
    var currentUser: MUser { set get }
    var chatsManager: ChatsManager { get }
    var postsManager: PostsManager { get }
    var firestoreManager: FirestoreManager { get }
    var usersManager: UsersManager { get }
}

protocol AuthManagersContainerProtocol: AnyObject {
    init(authManager: FirebaseAuthManager)
    var authManager: FirebaseAuthManager { get }
}

protocol ManagersModelContainerProtocol: AnyObject {
    init(currentUser: MUser, firestoreManager: FirestoreManager)
    var currentUser: MUser { get }
    var firestoreManager: FirestoreManager { get }
}

protocol InfoManagersContainerProtocol: AnyObject {
    init(firestoreManager: FirestoreManager?, authManager: FirebaseAuthManager?)
    var firestoreManager: FirestoreManager? { get }
    var authManager: FirebaseAuthManager? { get }
}

protocol MockMessage {
    var message: MMessage { get }
}
