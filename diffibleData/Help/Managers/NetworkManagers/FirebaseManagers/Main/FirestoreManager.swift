//
//  FirestoreManager.swift
//  diffibleData
//
//  Created by Arman Davidoff on 03.01.2021.
//  Copyright © 2021 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore

class FirestoreManager {
    
    let db = Firestore.firestore()
    
    var lastPostOfAll: DocumentSnapshot?
    var lastPostUser: DocumentSnapshot?
    var lastUser: DocumentSnapshot?
    
    var usersRef: CollectionReference {
        return db.collection("users")
    }
    var postsRef: CollectionReference {
        return db.collection("posts")
    }
    var currentUserID: String {
        return currentUser.id!
    }
    var currentUser: MUser
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
    }
}
