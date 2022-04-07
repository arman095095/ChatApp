//
//  AnswerViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 16.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

class AnswerViewModel {
    
    private let chat: MChat
    
    init(chat: MChat) {
        self.chat = chat
    }
    
    var currentChat: MChat {
        return chat
    }
    
    var name: String {
        return chat.friendUser!.name + ", " + "\(DateFormatManager().getAge(date: chat.friendUser!.birthday))"
    }
    
    var imageURL: URL? {
        return URL(string: chat.friendUser!.imageUrl)
    }
    
    
}
