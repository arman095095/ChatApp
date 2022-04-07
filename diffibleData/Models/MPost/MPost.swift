//
//  MPost.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class MPost {
    
    var userID: String?
    var likersIds: [String] = []
    var owner: MUser?
    var date: Date
    var id: String
    var textContent: String
    var urlImage: String?
    var imageSize: CGSize?
    var showedFullText = false
    var frames: Frames?
    var realFrames: Frames?
    var currentUserOwner: Bool = false
    var likedByMe: Bool = false
    
    init() {
        self.date = Date()
        self.id = ""
        self.textContent = ""
    }
    
    convenience init(textContent: String, urlImage: String? = nil) {
        self.init()
        self.date = Date().in(region: .current).date
        self.id = UUID().uuidString
        self.textContent = textContent
        self.urlImage = urlImage
    }
}

//MARK: Hashable
extension MPost: Hashable {
    
    static func == (lhs: MPost, rhs: MPost) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
