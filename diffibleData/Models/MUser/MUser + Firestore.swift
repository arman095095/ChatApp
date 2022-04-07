//
//  MUser + Firestore.swift
//  diffibleData
//
//  Created by Arman Davidoff on 21.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore

//MARK: FirebaseFirestore
extension MUser {
    
    func convertModelToDictionary() -> [String: Any] { //For send Model to Firebase as Dictionary
        var muserDictionary: [String: Any] = ["uid":id!]
        muserDictionary["username"] = userName
        muserDictionary["info"] = info
        muserDictionary["sex"] = sex
        muserDictionary["imageURL"] = imageUrl
        muserDictionary["birthday"] = birthday
        muserDictionary["country"] = country
        muserDictionary["city"] = city
        muserDictionary["removed"] = removed
        muserDictionary["online"] = online
        muserDictionary["lastActivity"] = FieldValue.serverTimestamp()
        
        return muserDictionary
    }
    
    convenience init?(dict: [String: Any]) {
        self.init()
        guard let userName = dict["username"] as? String,
        let info = dict["info"] as? String,
        let sex = dict["sex"] as? String,
        let imageURL = dict["imageURL"] as? String,
        let birthDay = dict["birthday"] as? String,
        let country = dict["country"] as? String,
        let city = dict["city"] as? String,
        let removed = dict["removed"] as? Bool,
        let online = dict["online"] as? Bool,
        let lastActivity = dict["lastActivity"] as? Timestamp,
        let identifier = dict["uid"] as? String else {
            return nil
        }
        
        self.userName = userName
        self.info = info
        self.sex = sex
        self.imageUrl = imageURL
        self.id = identifier
        self.birthday = birthDay
        self.country = country
        self.city = city
        self.removed = removed
        self.online = online
        self.lastActivity = lastActivity.dateValue()
    }
    
    convenience init?(documentSnapshot: DocumentSnapshot ) { //For convert from FireBaseDataSnapshot to ourModel
        self.init()
        guard let muserDictionary = documentSnapshot.data() else { return nil }
        self.init(dict: muserDictionary)
    }
    
    convenience init?(queryDocumentSnapshot: QueryDocumentSnapshot) { //For convert from FireBaseDataQuerySnapshot to ourModel
        self.init()
        let muserDictionary = queryDocumentSnapshot.data()
        self.init(dict: muserDictionary)
    }
}
