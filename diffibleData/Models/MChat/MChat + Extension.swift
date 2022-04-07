//
//  MChat + Extension.swift
//  diffibleData
//
//  Created by Arman Davidoff on 21.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import RealmSwift

//MARK: Help
extension MChat {
    
    var messages: List<MMessage> {
        return listMessages
    }
    
    var messagesCount: Int {
        return listMessages.count
    }
    
    var lastMessage: MMessage? {
        return listMessages.last
    }
    
    func newMessagesCount() -> Int {
        return listNewMessages.count
    }
    
    func existsNewMessages() -> Bool {
        return !listNewMessages.isEmpty
    }
    
    private func markFirstToday(message: MMessage) {
        if messages.isEmpty {
            try! RealmManager.realm?.write { message.firstOfDate = true }
            return
        }
        let messageDate = DateFormatManager().getLocaleDate(date: message.date!)
        let lastMessageDate = DateFormatManager().getLocaleDate(date: lastMessage!.date!)
        if !(lastMessageDate.day == messageDate.day && lastMessageDate.month == messageDate.month && lastMessageDate.year == messageDate.year) {
            try! RealmManager.realm?.write { message.firstOfDate = true }
        }
    }
}

//MARK: Remove & Appending Messages
extension MChat {
    
    func append(_ message: MMessage) {
        markFirstToday(message: message)
        try! RealmManager.realm?.write {
            self.listMessages.append(message) }
    }
    
    func append(notLooked: MMessage) {
        try! RealmManager.realm?.write {
            self.notLookedMessages.append(notLooked)
        }
    }
    
    func append(noLooked: List<MMessage>) {
        try! RealmManager.realm?.write {
            self.notLookedMessages.append(objectsIn: noLooked)
        }
    }
    
    func append(waiting: MMessage) {
        try! RealmManager.realm?.write {
            self.notSendedMessages.append(waiting)
        }
    }
    
    func append(new: MMessage) {
        try! RealmManager.realm?.write {
            self.listNewMessages.append(new) }
    }
    
    func append(of messages: [MMessage]) {
        markFirstToday(message: messages.first!)
        try! RealmManager.realm?.write {
            self.listMessages.append(objectsIn: messages) }
    }
    
    func append(ofNew messages: [MMessage]) {
        try! RealmManager.realm?.write {
            self.listNewMessages.append(objectsIn: messages) }
    }
    
    func removeAllNewMessages() {
        try! RealmManager.realm?.write {
            self.listNewMessages.removeAll()
        }
    }
    
    func removeAllMessages() {
        removeAllNewMessages()
        removeNotLookedMessages()
        removeNotSendedMessages()
        try! RealmManager.realm?.write {
            listMessages.removeAll()
        }
    }
    
    func removeNotLookedMessages() {
        try! RealmManager.realm?.write {
            self.notLookedMessages.removeAll()
        }
    }
    
    func removeNotSendedMessages() {
        try! RealmManager.realm?.write {
            self.notSendedMessages.removeAll()
        }
    }
}
