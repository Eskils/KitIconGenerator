//
//  CPColor.swift
//  CrossPlatform
//
//  Created by Eskil Gjerde Sviggum on 21/11/2023.
//

#if canImport(UIKit)

import UIKit
public typealias CPColor = UIColor

public extension CGColor {
    static var white: CGColor {
        CGColor(gray: 1, alpha: 1)
    }
    
    static var black: CGColor {
        CGColor(gray: 0, alpha: 1)
    }
}

#elseif canImport(Cocoa)

import Cocoa
public typealias CPColor = NSColor

public extension CPColor {
    static var tertiaryLabel: CPColor {
        CPColor.tertiaryLabelColor
    }
    
    static var systemGroupedBackground: CPColor {
        CPColor.windowBackgroundColor
    }
    
    static var secondarySystemGroupedBackground: CPColor {
        CPColor.controlBackgroundColor
    }
}


#endif
