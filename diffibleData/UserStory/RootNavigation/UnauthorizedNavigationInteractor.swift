//
//  UnauthorizedNavigationInteractor.swift
//  diffibleData
//
//  Created by Арман Чархчян on 22.04.2022.
//  Copyright (c) 2022 Arman Davidoff. All rights reserved.
//

import UIKit

protocol UnauthorizedNavigationInteractorInput: AnyObject {
    
}

protocol UnauthorizedNavigationInteractorOutput: AnyObject {
    
}

final class UnauthorizedNavigationInteractor {
    
    weak var output: UnauthorizedNavigationInteractorOutput?
}

extension UnauthorizedNavigationInteractor: UnauthorizedNavigationInteractorInput {
    
}
