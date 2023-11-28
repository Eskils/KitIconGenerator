//
//  SFNameAvailabilityHelper.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import Foundation

struct SFNameAvailabilityHelper {
    
    static func readNameAvailabilityFile(file: URL) throws -> NameAvailability {
        let data = try Data(contentsOf: file)

        let decoder = PropertyListDecoder()
        return try decoder.decode(NameAvailability.self, from: data)
    }

    static func groupSymbolsByYear(symbols: [Symbol]) -> [String: [Symbol]] {
        let symbols = symbols.sorted(by: { $0.year < $1.year })
        var dictionary = [String: [Symbol]]()
        var startIndex = 0
        var endIndex = 0
        
        guard var currentYear = symbols.first?.year else {
            return [:]
        }
        
        while endIndex < symbols.count {
            let symbol = symbols[endIndex]
            let year = symbol.year
            
            if currentYear != year
            || endIndex == symbols.count - 1 {
                let symbols = (endIndex != symbols.count - 1)
                    ? symbols[startIndex..<endIndex]
                    : symbols[startIndex...endIndex]
                 dictionary[currentYear] = Array(symbols).sorted(by: { $0.name < $1.name })
                 startIndex = endIndex
                 currentYear = year
            }
            
            endIndex += 1
        }
        
        return dictionary
    }
    
    static func makeGoupedSymbols(from nameAvailability: NameAvailability) -> [String: [Symbol]] {
        let symbols = nameAvailability.symbols.map { (symbolName, year) in
            Symbol(name: symbolName, release: nameAvailability.yearToRelease[year]!, year: year)
        }
        
        return Self.groupSymbolsByYear(symbols: symbols)
    }
    
}
