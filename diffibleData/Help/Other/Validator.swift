//
//  MailPasswordCheckerFuncks.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit


class Validator {
    
    func checkFilledSignUp(email:String?,password:String?,comformPassword:String?) -> Bool {
        if email == nil || password == nil || comformPassword == nil || email == "" || password == "" || comformPassword == "" { return false }
        else { return true }
    }
    
    func checkAgeNoLess16(date: String) -> Bool {
        return !(Int(DateFormatManager().getAge(date: date))! < 16)
    }
    
    func chackAgeValidation(date: String) -> Bool {
        let age = Int(DateFormatManager().getAge(date: date))!
        return !(age > 120 || age < 1)
    }
    
    func checkFilledLogin(email:String?,password:String?) -> Bool {
        if email == nil || password == nil || email == "" || password == "" { return false }
        else { return true }
    }
    
    func checkImageAdd(userImage: UIImage) -> Bool {
        let image = UIImage(named: "people")
        if userImage == image {
            return false
        } else { return true }
    }
    
    func checkFilledInfo(username:String?,info:String?,sex:String?, birthday: String?, countryCity: String?) -> Bool {
        if username == nil || info == nil || sex == nil || birthday == nil || countryCity == nil || username == "" || info == "" || sex == "" || birthday == "" || countryCity == ""  { return false }
        else { return true }
    }
    
    func mailCorrectForm(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: email) { return false }
        else { return true }
    }
    
    func passwordsEquel(password:String,comformPassword:String) -> Bool {
        if password != comformPassword { return false }
        else { return true }
    }
}
