//
//  Realm.swift
//  diffibleData
//
//  Created by Arman Davidoff on 03.03.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//


import UIKit
import RealmSwift

class MMessage: Object {
   
    @objc dynamic var senderUser: MUser?
    @objc dynamic var adressUser: MUser?
    @objc dynamic var senderID: String?
    @objc dynamic var adressID: String?
    @objc dynamic var content: String?
    @objc dynamic var date: Date?
    @objc dynamic var id : String?
    @objc dynamic var firstOfDate: Bool = false
    @objc dynamic var photoURL: String?
    @objc dynamic var audioURL: String?
    @objc dynamic var audioDuration: Float = 0.0
    @objc dynamic var imageData: Data?
    @objc dynamic var imageRatio: Double = 0.0
    @objc dynamic var sendingStatus: String = ""
    
    convenience init(sender: MUser, adress: MUser, content: String, photoURL: String? = nil, audioURL: String? = nil, audioDuration: Float? = nil) {
        self.init()
        self.senderID = sender.id
        self.senderUser = sender
        self.adressID = adress.id
        self.adressUser = adress
        self.content = content
        self.date = Date()
        self.id = UUID().uuidString
        self.photoURL = photoURL
        self.audioURL = audioURL
        self.sendingStatus = Status.waiting.rawValue
        self.audioDuration = audioDuration == nil ? 0.0 : audioDuration!
    }
}

//MARK: Other
extension MMessage {
    
    enum Status: String {
        case waiting
        case sended
        case looked
        case error
    }
    
    var status: Status? {
        return Status(rawValue: sendingStatus)
    }
}
