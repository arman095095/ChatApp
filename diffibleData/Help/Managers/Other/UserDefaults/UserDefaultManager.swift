//
//  UserDefaultManager.swift
//  diffibleData
//
//  Created by Arman Davidoff on 03.01.2021.
//  Copyright © 2021 Arman Davidoff. All rights reserved.
//

import Foundation

class UserDefaultManager {
    
    func getObject<T: NSObject&NSCoding>(type: T.Type, key: String) -> T? {
        guard let savedData = UserDefaults.standard.object(forKey: key) as? Data, let decodedModel = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? T else { return nil }
        return decodedModel
    }
    
    func createObjectAndSave<T: NSObject&NSCoding>(model: T, key: String) {
        guard let savedData = try? NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: false) else { fatalError() }
        UserDefaults.standard.set(savedData, forKey: key)
    }
    
    func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
}
