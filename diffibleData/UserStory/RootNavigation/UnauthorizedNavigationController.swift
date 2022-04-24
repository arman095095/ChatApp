//
//  UnauthorizedNavigationViewController.swift
//  diffibleData
//
//  Created by Арман Чархчян on 22.04.2022.
//  Copyright (c) 2022 Arman Davidoff. All rights reserved.
//

import UIKit

protocol UnauthorizedNavigationViewInput: AnyObject {
    
}

final class UnauthorizedNavigationController: UINavigationController {
    var output: UnauthorizedNavigationViewOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        output?.viewDidLoad()
    }
    
}

extension UnauthorizedNavigationController: UnauthorizedNavigationViewInput {
    
}
