//
//  TextMessageSizeCalculatorCustom.swift
//  diffibleData
//
//  Created by Arman Davidoff on 11.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import MessageKit

class TextMessageSizeCalculatorCustom: TextMessageSizeCalculator {
    
    func setup() {
        outgoingAvatarSize = .zero
        incomingAvatarSize = .zero
        
        incomingMessageLabelInsets.bottom = outgoingMessageLabelInsets.top + 3
        incomingMessageLabelInsets.right = 52
        outgoingMessageLabelInsets.bottom = outgoingMessageLabelInsets.top + 3
        outgoingMessageLabelInsets.right = 62
    }
    
    override func messageContainerSize(for message: MessageType) -> CGSize {
        let mock = MockTextMessage(message: message as! MMessage)
        return super.messageContainerSize(for: mock)
    }
}