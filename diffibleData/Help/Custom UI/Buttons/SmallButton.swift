//
//  SmallButton.swift
//  diffibleData
//
//  Created by Arman Davidoff on 28.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class SmallButton: UIButton {

    // MARK: - Functions

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(
            x: self.bounds.origin.x - 20.0,
            y: self.bounds.origin.y - 20.0,
            width: self.bounds.size.width + 40,
            height: self.bounds.size.height + 40
        )
        return newArea.contains(point)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
