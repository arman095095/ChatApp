//
//  MUser + CellModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 21.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

//MARK: Model
extension MUser {
    
    func containts(text: String?) -> Bool { //Функция для поиска по UserName для SearchController
        if text == nil { return true }
        if text!.isEmpty { return true }
        if text == "" { return true }
        return userName.lowercased().contains(text!.lowercased())
    }
    
    var name: String {
        return removed ? "DELETED" : userName
    }
    
    var photoURL: String {
        return removed ? "https://sun9-29.userapi.com/c851432/v851432354/d0fd2/bb_PEr06Thg.jpg" : imageUrl
    }
    
    var countryCityName: String {
        return country + ", " + city
    }
}
