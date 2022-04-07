//
//  Photo.swift
//  diffibleData
//
//  Created by Arman Davidoff on 16.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import MessageKit

struct Photo: MediaItem {
    
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    static func imageSize(ratio: Double) -> CGSize {
        let height: CGFloat = UIScreen.main.bounds.height / 3
        let width = height*CGFloat(ratio)
        return CGSize(width: width, height: height)
    }
}

struct Audio: AudioItem {
    
    var url: URL
    
    var duration: Float
    
    var size: CGSize = CGSize(width: 250, height: 70)
}
