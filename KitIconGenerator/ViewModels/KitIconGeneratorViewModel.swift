//
//  KitIconGeneratorViewModel.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 29/11/2023.
//

import Foundation
import KitIconRenderer
import CoreImage
import CrossPlatform

class KitIconGeneratorViewModel: ObservableObject {
    
    let context: CIContext
    
    let kitIconRenderer: KitIconRenderer
    
    @Published
    var renderedImage: CPImage?
    
    init() {
        self.context = CIContext()
        self.kitIconRenderer = KitIconRenderer(context: context)
    }
    
}
