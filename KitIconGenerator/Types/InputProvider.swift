//
//  InputProvider.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 29/11/2023.
//

import Foundation

enum InputProvider: CaseIterable {
    case image
    case systemSymbol
    
    var title: String {
        switch self {
        case .image:
            "Image"
        case .systemSymbol:
            "System symbol"
        }
    }
}
