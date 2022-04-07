//
//  UIScrollView.swift
//  diffibleData
//
//  Created by Arman Davidoff on 02.03.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import MessageKit

extension UIScrollView {
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForBottom: CGFloat {
        return contentSize.height + contentInset.bottom - bounds.height
    }
    
    func scrollToBottom(animated: Bool,height: CGFloat = 0) {
         if self.contentSize.height < self.bounds.size.height { return }
         let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + height)
         self.setContentOffset(bottomOffset, animated: animated)
    }
}
