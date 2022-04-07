//
//  LabelExtention.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(text: String,font: UIFont? = UIFont.avenir18()) {
        self.init()
        self.text = text
        if font != nil {
            self.font = font
        }
    }
}
