//
//  StructUserHashable.swift
//  diffibleData
//
//  Created by Arman Davidoff on 22.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import RealmSwift

class MUser: Object {
    
    @objc dynamic var userName: String = ""
    @objc dynamic var info: String = ""
    @objc dynamic var sex: String = ""
    @objc dynamic var imageUrl: String = ""
    @objc dynamic var id: String?
    @objc dynamic var country: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var birthday: String = ""
    @objc dynamic var removed: Bool = false
    @objc dynamic var online: Bool = true
    @objc dynamic var lastActivity: Date?
    var postsCount: Int = 0
    var friendsIds = [String]()
    var iamblockedIds = [String]()
    var blockedIds = [String]()
    
    convenience init(userName: String, imageName: String, identifier: String, sex: String, info: String, birthDay: String, country: String, city: String, removed: Bool = false) {
        self.init()
        self.userName = userName.capitalized
        self.imageUrl = imageName
        self.id = identifier
        self.info = info
        self.sex = sex
        self.birthday = birthDay
        self.country = country
        self.city = city
        self.removed = removed
        self.lastActivity = Date()
    }
}

//MARK: Help
extension MUser {
    
    func removeUser() {
        try! RealmManager.realm?.write {
            self.removed = true
        }
    }
    
    func recoverUser() {
        try! RealmManager.realm?.write {
            self.removed = false
        }
    }
    
    func updateInfo(with user: MUser) {
        try! RealmManager.realm?.write {
            self.userName = user.userName
            self.imageUrl = user.imageUrl
            self.info = user.info
            self.sex = user.sex
            self.online = user.online
            self.birthday = user.birthday
            self.country = user.country
            self.city = user.city
            self.removed = user.removed
            self.lastActivity = user.lastActivity
            self.postsCount = user.postsCount
        }
    }
    
    func equalForChatUpdate(user: MUser) -> Bool {
        return user.online == self.online && user.removed == self.removed && user.userName == self.userName && user.imageUrl == self.imageUrl && self.lastActivity == user.lastActivity
    }
}
