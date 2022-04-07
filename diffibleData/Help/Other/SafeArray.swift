//
//  SafeArray.swift
//  diffibleData
//
//  Created by Arman Davidoff on 17.05.2021.
//  Copyright © 2021 Arman Davidoff. All rights reserved.
//

import Foundation

class SArray<T> {
    
    private var array = [T]()
    private let queue = DispatchQueue(label: "safeArray", qos: .userInitiated, attributes: .concurrent)
    
    var value: [T] {
        var elements = [T]()
        queue.sync { [unowned self] in
            elements = self.array
        }
        return elements
    }
    
    func append(_ element: T) {
        queue.async(flags: .barrier) { [weak self] in
            self?.array.append(element)
        }
    }
}
