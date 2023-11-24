//
//  URL+Extension.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 22/11/2023.
//

import Foundation

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}
