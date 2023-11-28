//
//  NameAvailability.swift
//  SFSymbolsHunter
//
//  Created by Eskil Gjerde Sviggum on 02/11/2022.
//

import Foundation

struct NameAvailability: Decodable {
    let symbols: [String: String]
    let yearToRelease: [String: Release]
    
    enum CodingKeys: String, CodingKey {
        case symbols,
             yearToRelease = "year_to_release"
    }
}
