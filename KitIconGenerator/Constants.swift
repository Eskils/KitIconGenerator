//
//  Constants.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import Foundation

struct Constants {
    
    private init() {}
    
    /// Path to SFSymbols application
    static let sfSymbolsPath = "/Applications/SF Symbols.app"
    
    /// Path to NameAvailability plist. Relative to SFSymbols app.
    static let nameAvailabilityPath = "/Contents/Resources/Metadata/name_availability.plist"
    
}
