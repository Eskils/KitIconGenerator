//
//  Symbol.swift
//  SFSymbolsHunter
//
//  Created by Eskil Gjerde Sviggum on 02/11/2022.
//

import Foundation

struct Symbol: CustomStringConvertible {
    let name: String
    let release: Release
    let year: String

    var description: String {
        "[\(name)] @ \(year)"
    }
}
