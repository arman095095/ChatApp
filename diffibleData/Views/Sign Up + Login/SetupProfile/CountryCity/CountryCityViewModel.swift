//
//  CountryCityViewModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 04.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

class CountryCityViewModel {
    
    private enum ListType {
        case countries
        case cities
    }
    
    private var type: ListType = .countries
    private var objects: [AreaType]?
    private var filteredObjects: [AreaType]?
    
    
    init(selectedItem: AreaType? = nil) {
        if selectedItem == nil {
            self.type = .countries
            self.objects = Regions().getCountries()
        } else {
            guard let country = selectedItem as? Regions.Country else { return }
            self.type = .cities
            self.objects = Regions().getCities(country: country)
        }
        filteredObjects = objects
    }
    
    var title: String {
        switch type {
        case .countries:
            return "Выберите страну"
        case .cities:
            return "Выберите город"
        }
    }
    
    func search(text: String?) {
        filteredObjects = objects?.filter { $0.containts(text: text) }
    }
    
    var numberOfRows: Int {
        switch type {
        case .countries:
            guard let countries = filteredObjects as? [Regions.Country] else { return 0 }
            return countries.count
        case .cities:
            guard let cities = filteredObjects as? [Regions.City] else { return 0 }
            return cities.count
        }
    }
    
    func nameItem(at indexPath: IndexPath) -> String? {
        switch type {
        case .countries:
            return (filteredObjects?[indexPath.row] as? Regions.Country)?.description
        case .cities:
            return (filteredObjects?[indexPath.row] as? Regions.City)?.description
        }
    }
    
    func selectItem(at indexPath: IndexPath) -> AreaType? {
        switch type {
        case .countries:
            return filteredObjects?[indexPath.row] as? Regions.Country
        case .cities:
            let city = filteredObjects?[indexPath.row] as? Regions.City
            sendNotification(type: .updateContryCity, city: city)
            return nil
        }
    }
    
    func sendNotification(type: SetupProfileViewModel.NotificationName, city: Regions.City?) {
        guard let city = city else { return }
        switch type {
        case .updateContryCity:
            let dict = ["city": city.toDictionary()]
            NotificationCenter.default.post(.init(name: type.NSNotificationName, object: nil, userInfo: dict))
        }
    }
    
}
