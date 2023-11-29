//
//  clamp.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import Foundation

func clamp<T: Comparable>(_ value: T, _ minval: T, _ maxval: T) -> T {
    min(maxval, max(minval, value))
}
