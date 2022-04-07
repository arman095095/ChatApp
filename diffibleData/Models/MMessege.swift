//
//  StructMessegeHashable.swift
//  diffibleData
//
//  Created by Arman Davidoff on 29.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MessageKit

struct MMessege: Hashable, MessageType {
    
    
    var sender: SenderType {
        return Sender(senderId: senderId, displayName: senderUserName)
    }
    
    var messageId: String {
        return id
    }
    
    var sentDate: Date {
        return date
    }
    
    var kind: MessageKind {
        return .text(content)
    }
    
    
    var senderId: String
    var senderUserName: String
    var content: String
    var photoURL: URL?
    var date: Date
    var id: String
    var image:UIImage?
    
    init(message:MessageObject) {
        self.senderId = message.senderId!
        self.senderUserName = message.senderUserName!
        self.content = message.content!
        self.date = message.date!
        self.id = message.id!
    }
    
    func convertModelToDictionary() -> [String:Any] { //For send Model to Firebase as Dictionary
        var mmessegeDictionary:[String:Any] = ["senderId":senderId]
        mmessegeDictionary["senderUserName"] = senderUserName
        mmessegeDictionary["date"] = date
        mmessegeDictionary["id"] = id
        mmessegeDictionary["content"] = content
        
        if self.photoURL != nil {
            mmessegeDictionary["photoURL"] = photoURL!.absoluteString
        }
        
        return mmessegeDictionary
    }
    
    init?(queryDocumentSnapshot: QueryDocumentSnapshot ) { //For convert from FireBaseDataQuerySnapshot to ourModel
        let mmessegeDictionary = queryDocumentSnapshot.data()
        
        guard let senderUserName = mmessegeDictionary["senderUserName"] as? String,
        let id = mmessegeDictionary["id"] as? String,
        let date = mmessegeDictionary["date"] as? Timestamp,
        let content = mmessegeDictionary["content"] as? String,
        let senderId = mmessegeDictionary["senderId"] as? String else { return nil }
        
        if let urlPhotoString = mmessegeDictionary["photoURL"] as? String, let urlPhoto = URL(string: urlPhotoString) {
            self.photoURL = urlPhoto
        }
        
        
        self.senderUserName = senderUserName
        self.content = content
        self.date = date.dateValue()
        self.senderId = senderId
        self.id = id
       
    }
    init(mUser:MUser,content: String,photoURL: URL? = nil) {
        self.senderId = mUser.identifier
        self.senderUserName = mUser.userName
        self.content = content
        self.date = Date()
        self.id = UUID().uuidString
        self.photoURL = photoURL
        
    }
    
    //Методы для соответствия протоколу Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.messageId)
    }
    static func == (lhs: MMessege, rhs: MMessege) -> Bool {
        return lhs.messageId == rhs.messageId
    }
   
}
