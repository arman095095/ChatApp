//
//  PhotoMessageSizeCalculatorCustom.swift
//  diffibleData
//
//  Created by Arman Davidoff on 11.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import MessageKit

class PhotoMessageSizeCalculatorCustom: MediaMessageSizeCalculator {
    
    func setup() {
        outgoingAvatarSize = .zero
        incomingAvatarSize = .zero
    }
    
    override func messageContainerSize(for message: MessageType) -> CGSize {
        let mock = MockPhotoMessage(message: message as! MMessage)
        return super.messageContainerSize(for: mock)
    }
}
