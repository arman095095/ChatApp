//
//  MMessage + MessageKit.swift
//  diffibleData
//
//  Created by Arman Davidoff on 21.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import MessageKit

//MARK: MessageKit MessageType
extension MMessage: MessageType {
    
    class Sender: SenderType {
        var senderId: String
        
        var displayName: String
        
        init(senderId: String, displayName: String) {
            self.senderId = senderId
            self.displayName = displayName
        }
    }

    var sender: SenderType {
        return Sender(senderId: senderID!, displayName: senderUser!.userName)
    }
      
    var messageId: String {
        return id!
    }
      
    var sentDate: Date {
        return date!
    }
      
    var kind: MessageKind {
        if let imageData = imageData, let image = UIImage(data: imageData) {
            return .custom(MessageKind.photo(Photo(url: nil, image: image, placeholderImage: #imageLiteral(resourceName: "placeholder"), size: Photo.imageSize(ratio: imageRatio))))
        } else if let imageURL = photoURL {
            return .custom(MessageKind.photo(Photo(url: URL(string: imageURL), image: nil, placeholderImage: #imageLiteral(resourceName: "placeholder"), size: Photo.imageSize(ratio: imageRatio))))
        }
        else if let urlString = audioURL, let url = URL(string: urlString) {
            return .custom(MessageKind.audio(Audio(url: url, duration: audioDuration)))
        } else if let content = content {
            return .custom(MessageKind.text(content))
        } else {
            return .text("")
        }
    }
}
