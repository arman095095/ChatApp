//
//  UnauthorizedNavigationViewController.swift
//  diffibleData
//
//  Created by Арман Чархчян on 22.04.2022.
//  Copyright (c) 2022 Arman Davidoff. All rights reserved.
//

import UIKit

protocol RootNavigationViewInput: AnyObject {
    
}

final class RootNavigationController: UINavigationController {
    var output: RootNavigationViewOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        output?.viewDidLoad()
    }
    
}

extension RootNavigationController: RootNavigationViewInput {
    
}
