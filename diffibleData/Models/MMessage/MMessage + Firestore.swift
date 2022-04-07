//
//  MMessage + Firestore.swift
//  diffibleData
//
//  Created by Arman Davidoff on 21.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation
import FirebaseFirestore

//MARK: FirebaseFirestore
extension MMessage {
    
    func clone() -> MMessage {
        let message = MMessage()
        message.senderID = self.senderID
        message.adressID = self.adressID
        message.content = self.content
        message.date = self.date
        message.id = self.id
        message.firstOfDate = self.firstOfDate
        message.photoURL = self.photoURL
        message.imageData = self.imageData
        message.audioURL = self.audioURL
        message.audioDuration = self.audioDuration
        message.imageRatio = self.imageRatio
        return message
    }
    
    func convertModelToDictionary() -> [String: Any] {
        var mmessegeDictionary: [String:Any] = [:]
        mmessegeDictionary["date"] = FieldValue.serverTimestamp()
        mmessegeDictionary["senderID"] = senderID
        mmessegeDictionary["adressID"] = adressID
        mmessegeDictionary["id"] = id
        mmessegeDictionary["content"] = content
        
        if let photoUrl = self.photoURL {
            mmessegeDictionary["photoURL"] = photoUrl
            mmessegeDictionary["imageRatio"] = imageRatio
        }
        if let audioURL = self.audioURL {
            mmessegeDictionary["audioURL"] = audioURL
            mmessegeDictionary["audioDuration"] = audioDuration
        }
        return mmessegeDictionary
    }
    
    convenience init?(queryDocumentSnapshot: QueryDocumentSnapshot) {
        self.init()
        let mmessegeDictionary = queryDocumentSnapshot.data()
        
        guard let senderID = mmessegeDictionary["senderID"] as? String,
        let id = mmessegeDictionary["id"] as? String,
        let date = mmessegeDictionary["date"] as? Timestamp,
        let content = mmessegeDictionary["content"] as? String,
        let adressID = mmessegeDictionary["adressID"] as? String
        else { return nil }
        
        if let urlPhotoString = mmessegeDictionary["photoURL"] as? String, let imageRatio = mmessegeDictionary["imageRatio"] as? Double {
            self.photoURL = urlPhotoString
            self.imageRatio = imageRatio
        }
        if let audioURL = mmessegeDictionary["audioURL"] as? String {
            self.audioURL = audioURL
            self.audioDuration = mmessegeDictionary["audioDuration"] as? Float ?? 0.0
        }
        self.senderID = senderID
        self.adressID = adressID
        self.content = content
        self.date = date.dateValue()
        self.id = id
    }
}
