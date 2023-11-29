//
//  PreviewView.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 29/11/2023.
//

import SwiftUI
import SceneKit
import CrossPlatform

struct PreviewView: View {
    
    @ObservedObject
    var viewModel: KitIconGeneratorViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                #if DEBUG
                // In order to inspect the SCNScene with View Hierarchy Capture
                SceneView(scene: viewModel.kitIconRenderer.scene)
                    .frame(width: 1, height: 1)
                    .opacity(0)
                #endif
                
                if let renderedImage = viewModel.renderedImage {
                    Image(cpImage: renderedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 500, maxHeight: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            Spacer()
        }
        .background(Color(CPColor.systemGroupedBackground))
    }
}
