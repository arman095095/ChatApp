//
//  RealmManager.swift
//  diffibleData
//
//  Created by Arman Davidoff on 21.05.2021.
//  Copyright © 2021 Arman Davidoff. All rights reserved.
//

import RealmSwift
import Realm

class RealmManager {
    
    private(set) static var realm: Realm?
    private static var count: Int = 0
    
    static func initiate(userID: String) {
        guard count == 0 else { return }
        var configuration = Realm.Configuration()
        configuration.fileURL = FileManager.getDocumentsDirectory().appendingPathComponent("\(userID).realm")
        realm = try! Realm(configuration: configuration)
        count += 1
    }
    
    static func deinitalize() {
        guard count == 1 else { return }
        realm = nil
        count -= 1
    }
}
