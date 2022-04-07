//
//  UIImageSizeSet.swift
//  diffibleData
//
//  Created by Arman Davidoff on 28.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import Foundation

extension UIImage { //Уменьшает размер изображения
    
    var scaledToSafeUploadSize: UIImage? { //Обращаться к этому свойсту
        let imageMaxSideLength: CGFloat = 480
        
        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > imageMaxSideLength ? largerSide / imageMaxSideLength : 1
        let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
        
        return image(scaledTo: newImageSize)
    }
    
    private func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndPDFContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
