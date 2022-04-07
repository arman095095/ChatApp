//
//  SetupProfileViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import FirebaseAuth
import RxCocoa
import RxSwift
import RxRelay

class SetupProfileViewModel {
    
    private var currentUser: User?
    private var editedUser: MUser?
    var successHandler: ((MUser) -> ())?
    var failureHandler: ((Error) -> ())?
    var city = BehaviorRelay<Regions.City?>.init(value: nil)
    private let checker = Validator()
    
    private var firestoreManager: FirestoreManager? {
        return infoManagers.firestoreManager
    }
    private var authManager: FirebaseAuthManager? {
        return infoManagers.authManager
    }
    
    var photoChanged: Bool = false
    var infoManagers: InfoManagersContainerProtocol
    
    init(currentUser: User?, editedUser: MUser?, infoManagers: InfoManagersContainerProtocol) {
        self.infoManagers = infoManagers
        self.currentUser = currentUser
        self.editedUser = editedUser
        initObservers()
    }
    
    var register: Bool {
        return currentUser != nil && editedUser == nil
    }
    
    deinit {
        removeObservers()
    }
    
    var buttonTitle: String {
        if register {
            return "Начать общение"
        } else {
            return "Сохранить"
        }
    }
    
    var cityDescription: String? {
        return city.value?.fullDescription
    }
    
    func dateDescription(date: Date) -> String {
        return DateFormatManager().getLocaleDate(date: date).toString(.custom(DateFormatManager().custom))
    }
    
    var title: String {
        return "Редактирование"
    }
    
    var titleLabel: String {
        return "Данные профиля"
    }
    
    var displayName: String {
        if register {
            return currentUser?.displayName ?? ""
        } else {
            return editedUser?.userName ?? ""
        }
    }
    
    var info: String? {
        if !register {
            return editedUser!.info
        }
        return nil
    }
    
    var sexIndex: Int {
        if !register {
            if editedUser!.sex == "Мужчина" {
                return 0
            } else {
                return 1
            }
        }
        return 0
    }
    
    var birthday: String? {
        if !register {
            return editedUser!.birthday
        }
        return nil
    }
    
    var birthdayDate: Date {
        if birthday == nil {
            return Date()
        } else {
            return DateFormatManager().ageDateFormatter.date(from: birthday!)!
        }
    }
    
    var countryCity: String? {
        if !register {
            return editedUser!.countryCityName
        }
        return nil
    }
    
    var photoURL: URL? {
        if register {
            return currentUser?.photoURL
        } else {
            return URL(string: editedUser!.imageUrl)
        }
    }
    
    func sendProfileInfo(userName: String?, info: String?, sex: String?, userImage: UIImage, birthday: String?, countryCity: String?) {
        guard checker.checkFilledInfo(username: userName, info: info, sex: sex, birthday: birthday, countryCity: countryCity) else {
            failureHandler?(ValidationError.notFilled)
            return
        }
        guard checker.chackAgeValidation(date: birthday!) else {
            failureHandler?(ValidationError.ageNotValid)
            return
        }
        guard checker.checkAgeNoLess16(date: birthday!) else {
            failureHandler?(ValidationError.ageLess16)
            return
        }
        guard checker.checkImageAdd(userImage: userImage) else {
            failureHandler?(ValidationError.photoNotAdded)
            return
        }
        let components = countryCity!.components(separatedBy: ", ")
        guard components.count == 2 else { fatalError() }
        let country = components[0]
        let city = components[1]
        
        if let _ = authManager, register {
            registration(userName: userName, info: info, sex: sex, userImage: userImage, birthday: birthday, country: country, city: city)
        } else if let _ = firestoreManager, !register {
            edit(userName: userName, info: info, sex: sex, userImage: userImage, birthday: birthday, country: country, city: city)
        }
    }
}

//MARK: Main operations
private extension SetupProfileViewModel {
    
    func registration(userName: String?, info: String?, sex: String?, userImage: UIImage, birthday: String?, country: String?, city: String?) {
        authManager?.createUserProfile(identifier: currentUser!.uid, username: userName!, info: info!, sex: sex!, country: country!, city: city!, birthday: birthday!, userImage: userImage) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let muser):
                self.successHandler?(muser)
            case .failure(let error):
                self.failureHandler?(error)
            }
        }
    }
    
    func edit(userName: String?, info: String?, sex: String?, userImage: UIImage?, birthday: String?, country: String?, city: String?) {
        
        let editUser = MUser(userName: userName!, imageName: "default", identifier: editedUser!.id!, sex: sex!, info: info!, birthDay: birthday!, country: country!, city: city!)
        let imageURL = photoChanged ? nil : editedUser?.imageUrl
        let photo = photoChanged ? userImage : nil
        
        firestoreManager?.editUserProfile(editedUser: editUser, photo: photo, imageURL: imageURL, complition: { [weak self] (result) in
            switch result {
            case .success(let muser):
                self?.successHandler?(muser)
            case .failure(let error):
                self?.failureHandler?(error)
            }
        })
        
    }
}

//MARK: UpdateModels
private extension SetupProfileViewModel {
    
    @objc func updateContryCity(notification: Notification) {
        guard let dict = notification.userInfo?["city"] as? [String: Any], let cityModel = Regions.City(dict: dict) else { return }
        city.accept(cityModel)
    }
}

//MARK: Observer
extension SetupProfileViewModel {
    enum NotificationName: String, CaseIterable {
        
        case updateContryCity
        
        var NSNotificationName: NSNotification.Name {
            return NSNotification.Name(self.rawValue)
        }
    }
    
    private func initObservers() {
        for name in NotificationName.allCases {
            switch name {
            case .updateContryCity:
                NotificationCenter.default.addObserver(self, selector: #selector(updateContryCity), name: name.NSNotificationName, object: nil)
            }
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
