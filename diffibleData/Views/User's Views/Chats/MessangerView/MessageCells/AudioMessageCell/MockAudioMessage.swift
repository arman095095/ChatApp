//
//  MockAudioMessage.swift
//  diffibleData
//
//  Created by Arman Davidoff on 11.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import MessageKit
import Foundation

struct MockAudioMessage: MessageType, MockMessage {
    var sender: SenderType {
        return message.sender
    }
    
    var messageId: String {
        return message.messageId
    }
    
    var sentDate: Date {
        return message.sentDate
    }
    
    var kind: MessageKind {
        let custom = message.kind
        switch custom {
        case .custom(let audioKind):
            let audio = audioKind as! MessageKind
            switch audio {
            case .audio(let audio):
                return .audio(audio)
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
    var message: MMessage
    
}
