//
//  ActiveChatViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 22.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import MessageKit

class ActiveChatViewModel {
    
    let chat: MChat
    
    init(chat: MChat) {
        self.chat = chat
    }
    
    var newMessagesCount: Int {
        return chat.newMessagesCount()
    }
    
    var newMessagesEnable: Bool {
        return newMessagesCount != 0
    }
    
    var online: Bool {
        return chat.friendUser!.online
    }
    
    var userName: String {
        return chat.friendUser!.name
    }
    
    var lastMessageMarkedImage: UIImage? {
        guard let message = chat.lastMessage, let status = message.status else { return nil }
        guard message.senderID == chat.ownerID else { return nil }
        switch status {
        case .waiting:
            return nil
        case .sended:
            return UIImage(named: "sended1")
        case .looked:
            return UIImage(named: "sended2")
        case .error:
            return nil
        }
    }
    
    var lastMessageContent: String {
        guard let message = chat.lastMessage else { return "" }
        if chat.typing { return "печатает..." }
        switch message.kind {
        case .custom(let kind):
            switch kind as! MessageKind {
            case .text(_):
                return message.content ?? ""
            case .audio(_):
                return "Голосовое сообщение"
            case .photo(_):
                return "Фотография"
            default:
                return ""
            }
        default:
            return ""
        }
    }
    
    var lastMessageDate: String {
        let date = chat.lastMessage!.date!
        return DateFormatManager().convertForActiveChat(from: date)
    }
    
    var imageURL: URL? {
        return URL(string: chat.friendUser!.photoURL)
    }
    
    private var removed: Bool {
        return chat.friendUser!.removed
    }
    
    var lastMessageType: MessageKind? {
        guard let message = chat.lastMessage else { return nil }
        return message.kind
    }
    
    var badgeWidth: CGFloat {
        let width = "\(newMessagesCount)".width(font: ChatsConstants.badgeTextFont) + ChatsConstants.badgeInset
        if width < ChatsConstants.badgeHeight { return ChatsConstants.badgeHeight }
        return width
    }
}
