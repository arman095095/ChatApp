//
//  StructEnumForDiffible.swift
//  diffibleData
//
//  Created by Arman Davidoff on 20.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RealmSwift

class MChat: Object  {
    
    @objc dynamic var ownerID: String?
    @objc dynamic var friendID: String?
    @objc dynamic var ownerUser: MUser?
    @objc dynamic var friendUser: MUser?
    @objc dynamic var active = false
    @objc dynamic var hideForID: String?
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var typing = false
    var listMessages = List<MMessage>()
    
    var listNewMessages = List<MMessage>()
    var notSendedMessages = List<MMessage>()
    var notLookedMessages = List<MMessage>()
    
    convenience init(friend: MUser, current: MUser) {
        self.init()
        self.friendUser = friend
        self.ownerUser = current
        self.friendID = friend.id
        self.ownerID = current.id
    }
    
    static override func primaryKey() -> String? {
        return "id"
    }
}
