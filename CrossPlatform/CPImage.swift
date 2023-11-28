//
//  CPImage.swift
//  CrossPlatform
//
//  Created by Eskil Gjerde Sviggum on 22/11/2023.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias CPImage = UIImage
#elseif canImport(Cocoa)
import Cocoa
public typealias CPImage = NSImage

public extension CPImage {
    
    var cgImage: CGImage? {
        self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    func pngData() -> Data? {
        let imageRepresentation = self.cgImage.map { NSBitmapImageRep(cgImage: $0) }
        return imageRepresentation?.representation(using: .png, properties: [:])
    }
    
    convenience init?(systemName: String) {
        self.init(systemSymbolName: systemName, accessibilityDescription: nil)
    }
    
    convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
    }
    
    func resize(to: CGSize) -> CPImage {
        let img = NSImage(size: to)

        img.lockFocus()
        defer {
            img.unlockFocus()
        }

        if let ctx = NSGraphicsContext.current {
            ctx.imageInterpolation = .high
            draw(in: NSRect(origin: .zero, size: to),
                 from: NSRect(origin: .zero, size: size),
                 operation: .copy,
                 fraction: 1)
        }

        return img
    }
    
}
#endif

public extension Image {
    init(cpImage: CPImage) {
        #if canImport(UIKit)
        self = Image(uiImage: cpImage)
        #elseif canImport(Cocoa)
        self = Image(nsImage: cpImage)
        #endif
    }
}
