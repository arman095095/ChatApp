//
//  MPost + Firestore.swift
//  diffibleData
//
//  Created by Arman Davidoff on 21.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseFirestore

//MARK: FirebaseFirestore
extension MPost {
    
    convenience init?(postDictionary: [String:Any]) {
        self.init()
        guard let id = postDictionary["id"] as? String,
              let date = postDictionary["date"] as? Timestamp,
              let textContent = postDictionary["textContent"] as? String,
              let userID = postDictionary["userID"] as? String
        else { return nil }
    
        self.userID = userID
        self.id = id
        self.textContent = textContent
        self.date = date.dateValue()
        
        if let urlImage = postDictionary["urlImage"] as? String {
            self.urlImage = urlImage
        }
        if let imageHeight = postDictionary["imageHeight"] as? CGFloat,let imageWidth = postDictionary["imageWidth"] as? CGFloat  {
            self.imageSize = CGSize(width: imageWidth, height: imageHeight)
        }
    }
    
    convenience init?(queryDocumentSnapshot: QueryDocumentSnapshot) {
        let postDictionary = queryDocumentSnapshot.data()
        self.init(postDictionary: postDictionary)
    }
    
    convenience init?(documentSnapshot: DocumentSnapshot) {
        guard let postDictionary = documentSnapshot.data() else { return nil }
        self.init(postDictionary: postDictionary)
    }
    
    func convertModelToDictionary() -> [String: Any] {
        var postDictionary: [String:Any] = ["userID": userID!]
        postDictionary["id"] = id
        postDictionary["textContent"] = textContent
        postDictionary["date"] = date
        
        if let urlImage = self.urlImage {
            postDictionary["urlImage"] = urlImage
        }
        if let imageSize = self.imageSize {
            postDictionary["imageHeight"] = imageSize.height
            postDictionary["imageWidth"] = imageSize.width
        }
        return postDictionary
    }
}
