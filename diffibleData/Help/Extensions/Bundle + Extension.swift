//
//  Bundle + Extension.swift
//  diffibleData
//
//  Created by Arman Davidoff on 04.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

extension Bundle {
    
    func decoder<T:Decodable>(model:T.Type,url: String) -> T {
        guard let url = self.url(forResource: url, withExtension: nil) else { fatalError("incorrect adress") }
        guard let data = try? Data.init(contentsOf: url) else { fatalError("error loading") }
        guard let load = try? JSONDecoder().decode(T.self, from: data) else { fatalError("error decoding") }
        return load
    }
}
