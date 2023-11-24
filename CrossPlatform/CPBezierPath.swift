//
//  CPBezierPath.swift
//  CrossPlatform
//
//  Created by Eskil Gjerde Sviggum on 21/11/2023.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias CPBezierPath = UIBezierPath
#elseif canImport(Cocoa)
import Cocoa
public typealias CPBezierPath = NSBezierPath
#endif

public extension CPBezierPath {
    /// /// Returns the path of a rounded rectangle with the specified dimensions and corner radius.
    static func roundedRectangle(rect: CGRect, radius: CGFloat) -> CPBezierPath {
        #if canImport(UIKit)
        CPBezierPath(roundedRect: rect, cornerRadius: radius)
        #elseif canImport(Cocoa)
        CPBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        #endif
    }
}
