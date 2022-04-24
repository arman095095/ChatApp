//
//  UnauthorizedNavigationInteractor.swift
//  diffibleData
//
//  Created by Арман Чархчян on 22.04.2022.
//  Copyright (c) 2022 Arman Davidoff. All rights reserved.
//

import UIKit

protocol RootNavigationInteractorInput: AnyObject {
    
}

protocol RootNavigationInteractorOutput: AnyObject {
    
}

final class RootNavigationInteractor {
    
    weak var output: RootNavigationInteractorOutput?
}

extension RootNavigationInteractor: RootNavigationInteractorInput {
    
}
