//
//  FileManager + Extension.swift
//  diffibleData
//
//  Created by Arman Davidoff on 05.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

extension FileManager {
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
