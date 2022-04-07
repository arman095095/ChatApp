//
//  NetworkManager.swift
//  diffibleData
//
//  Created by Arman Davidoff on 04.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import Foundation

class Regions {
    
    func getCountries() -> [Country] {
        return Country.allCases.map { $0 }
    }
    
    func getCities(country: Country) -> [City] {
        switch country {
        case .ru:
            let response = Bundle.main.decoder(model: [ResponseModelCitiesOther].self, url: "\(country.rawValue).json")
            return response.map { City(name: $0.city, country: country) }
        default:
            let response = Bundle.main.decoder(model: ResponseModelCities.self, url: "\(country.rawValue).json")
            return response.items.map { City(name: $0.name,country: country) }
        }
    }
}

//MARK: Decode Models
private extension Regions {
    // MARK: - Welcome
    struct ResponseModelCities: Decodable {
        let items: [Cities]
    }

    // MARK: - Item
    struct Cities: Decodable {
        let name: String
    }
    
    struct ResponseModelCitiesOther: Decodable {
        let city: String
    }
}

//MARK: Models
extension Regions {
    
    enum Country: String, CaseIterable, AreaType {
        
        case ru
        case uk
        case by
        case am
        case az
        case md
        case uzb
        case kgz
        case tjk
        case kz
        
        static func getCountry(description: String) -> Country? {
            switch description {
            case "Россия":
                return .ru
            case "Украина":
                return .uk
            case "Беларусь":
                return .by
            case "Армения":
                return .am
            case "Азербайджан":
                return .az
            case "Молдова":
                return .md
            case "Узбекистан":
                return .uzb
            case "Киргизия":
                return .kgz
            case "Таджикистан":
                return .tjk
            case "Казахстан":
                return .kz
            default:
                return nil
            }
        }
        
        var description: String {
            switch self {
            case .ru:
                return "Россия"
            case .uk:
                return "Украина"
            case .by:
                return "Беларусь"
            case .am:
                return "Армения"
            case .az:
                return "Азербайджан"
            case .md:
                return "Молдова"
            case .uzb:
                return "Узбекистан"
            case .kgz:
                return "Киргизия"
            case .tjk:
                return "Таджикистан"
            case .kz:
                return "Казахстан"
            }
        }
    }
    
    struct City: AreaType {
        private var country: Country
        private var name: String
        var description: String {
            return name
        }
        var fullDescription: String {
            return country.description + ", " + description
        }
        
        init(name: String, country: Country) {
            self.name = name
            self.country = country
        }
        
        init?(dict: [String: Any]) {
            guard let name = dict["name"] as? String,
                  let countryName = dict["countryName"] as? String,
                  let country = Country.getCountry(description: countryName) else { return nil }
            self.name = name
            self.country = country
        }
        
        func toDictionary() -> [String:Any] {
            var dict: [String: Any] = ["name": name]
            dict["countryName"] = country.description
            return dict
        }
    }
}
