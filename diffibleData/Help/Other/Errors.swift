//
//  AuthErrorsEnum.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

enum AuthError: LocalizedError {
    case notFilled
    case comformPassword
    case incorrectMail
    
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .comformPassword:
            return NSLocalizedString("Пароли не совпадают", comment: "")
        case .incorrectMail:
            return NSLocalizedString("Некорректный формат почты", comment: "")
        }
    }
}

enum GetUserInfoError: LocalizedError {
    case getData
    case convertData
    case profileRemoved(muser: MUser)
    
    var errorDescription: String? {
        switch self {
        case .getData:
            return NSLocalizedString("Ошибка получения данных", comment: "")
        case .convertData:
            return NSLocalizedString("Ошибка конвертации данных", comment: "")
        case .profileRemoved:
            return NSLocalizedString("Ваш профиль был удален", comment: "")
        }
    }
}

enum ValidationError: LocalizedError {
    case notFilled
    case photoNotAdded
    case ageLess16
    case ageNotValid
    
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .photoNotAdded:
            return NSLocalizedString("Вы не добавили фото", comment: "")
        case .ageLess16:
            return NSLocalizedString("Вам нет 16-ти лет", comment: "")
        case .ageNotValid:
            return NSLocalizedString("Пожалуйста, введите корректную дату рождения", comment: "")
        }
    }
}

enum ConnectionError: LocalizedError {
    case noInternet
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Нет интернета"
        }
    }
}
