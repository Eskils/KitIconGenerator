//
//  CGImage+Extension.swift
//  KitIconRenderer
//
//  Created by Eskil Gjerde Sviggum on 22/11/2023.
//

import CoreImage

extension CGImage {
    
    func underlay(color: CGColor, context: CIContext) -> CGImage? {
        let extent = CGRect(x: 0, y: 0, width: width, height: height)
        let colorImage = CIImage(color: CIColor(cgColor: color))
            .clamped(to: extent)
        let composition = CIImage(cgImage: self).composited(over: colorImage)
        
        return context.createCGImage(composition, from: extent)
    }
    
}
