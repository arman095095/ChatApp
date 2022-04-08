//
//  CombineManagers.swift
//  diffibleData
//
//  Created by Arman Davidoff on 06.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

class ProfileManagersContainer: ProfileManagersContainerProtocol {
    
    var currentUser: MUser
    var chatsManager: ChatsManager
    var postsManager: PostsManager
    var firestoreManager: FirestoreManager
    var usersManager: UsersManager
    
    required init(currentUser: MUser, chatsManager: ChatsManager, postsManager: PostsManager, firestoreManager: FirestoreManager, usersManager: UsersManager) {
        self.currentUser = currentUser
        self.chatsManager = chatsManager
        self.postsManager = postsManager
        self.firestoreManager = firestoreManager
        self.usersManager = usersManager
    }
}

class AudioManagersContainer: AudioManagersContainerProtocol {
    
    required init(recorder: AudioMessageRecorder, player: AudioMessagePlayer) {
        self.recorder = recorder
        self.player = player
    }
    var recorder: AudioMessageRecorder
    var player: AudioMessagePlayer
}

class AuthManagersContainer: AuthManagersContainerProtocol {
    
    var authManager: FirebaseAuthManager
    
    required init(authManager: FirebaseAuthManager) {
        self.authManager = authManager
    }
}


class InfoManagersContainer: InfoManagersContainerProtocol {
    
    var firestoreManager: FirestoreManager?
    var authManager: FirebaseAuthManager?
    
    required init(firestoreManager: FirestoreManager?, authManager: FirebaseAuthManager?) {
        self.firestoreManager = firestoreManager
        self.authManager = authManager
    }
}

class ManagerModelContainer: ManagersModelContainerProtocol {
    
    var currentUser: MUser
    var firestoreManager: FirestoreManager
    
    required init(currentUser: MUser, firestoreManager: FirestoreManager) {
        self.currentUser = currentUser
        self.firestoreManager = firestoreManager
    }
}
