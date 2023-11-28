//
//  StringParseable.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import Foundation

protocol StringParseable {
    init?(string: String)
    static var zero: Self { get }
}

extension Float: StringParseable {
    init?(string: String) {
        self.init(string)
    }
}
