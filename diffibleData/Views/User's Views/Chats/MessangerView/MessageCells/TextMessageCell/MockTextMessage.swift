//
//  MockTextMessage.swift
//  diffibleData
//
//  Created by Arman Davidoff on 11.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import MessageKit
import Foundation

struct MockTextMessage: MessageType, MockMessage {
    
    var sender: SenderType {
        return message.sender
    }
    
    var messageId: String {
        message.messageId
    }
    
    var sentDate: Date {
        return message.sentDate
    }
    
    var kind: MessageKind {
        return .text(message.content!)
    }
    
    var message: MMessage
}
