//
//  Colorization.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import Combine
import SwiftUI
import CoreImage.CIFilterBuiltins
import CrossPlatform


class Colorization: ObservableObject {
    
    @Published
    var kind: Kind = .none {
        didSet {
            objectDidChange.send(())
        }
    }
    
    @Published
    var color: Color = .black {
        didSet {
            objectDidChange.send(())
        }
    }
    
    @Published
    var gradient: LinearGradientDescription = .init(color0: .white, color1: .black, point0: .zero, point1: CGPoint(x: 1, y: 1)) {
        didSet {
            objectDidChange.send(())
        }
    }
    
    let objectDidChange = CurrentValueSubject<Void, Never>(())
    
    func colorize(image: CPImage, backgroundColor: CPColor, context: CIContext) -> CPImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let imageSize = ciImage.extent.size
        var fillImage: CIImage?
        let backgroundImage = CIImage(color: CIColor(cgColor: backgroundColor.cgColor))
        
        switch kind {
        case .none:
            return image
        case .color:
            fillImage = makeColorImage(color: CPColor(self.color).cgColor, size: imageSize)
        case .gradient:
            fillImage = makeGradientImage(gradient: self.gradient, size: imageSize)
        }
        
        guard let fillImage else {
            return nil
        }
        
        let blendFilter = CIFilter.blendWithAlphaMask()
        blendFilter.backgroundImage = backgroundImage
        blendFilter.inputImage = fillImage
        blendFilter.maskImage = ciImage
        
        guard 
            let outputImage = blendFilter.outputImage,
            let outputCGImage = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: imageSize))
        else {
            return nil
        }
        
        return CPImage(cgImage: outputCGImage)
    }
    
    private func makeGradientImage(gradient gradientDescription: LinearGradientDescription, size: CGSize) -> CIImage? {
        let gradient = CIFilter.linearGradient()
        gradient.color0 = CIColor(cgColor: gradientDescription.color0)
        gradient.color1 = CIColor(cgColor: gradientDescription.color1)
        gradient.point0 = CGPoint(x: gradientDescription.point0.x * size.width, y: gradientDescription.point0.y * size.height)
        gradient.point1 = CGPoint(x: gradientDescription.point1.x * size.width, y: gradientDescription.point1.y * size.height)
        
        guard let gradientImage = gradient.outputImage else {
            return nil
        }
        
        return gradientImage.cropped(to: CGRect(origin: .zero, size: size))
    }
    
    private func makeColorImage(color: CGColor, size: CGSize) -> CIImage {
        let colorImage = CIImage(color: CIColor(cgColor: color))
        return colorImage.cropped(to: CGRect(origin: .zero, size: size))
    }
    
}

extension Colorization {
    enum Kind: CaseIterable {
        case none
        case color
        case gradient
        
        var title: String {
            switch self {
            case .none:
                "Use image colors"
            case .color:
                "Color"
            case .gradient:
                "Gradient"
            }
        }
    }
}
