//
//  ContentView.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 21/11/2023.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers
import Combine
import CrossPlatform
import KitIconRenderer
import ModelIO

struct ContentView: View {
    
    @StateObject
    var viewModel = KitIconGeneratorViewModel()
    
    var body: some View {
        
        Group {
            #if os(macOS)
            NavigationView {
                ToolbarView(viewModel: viewModel, center: true)
                    .listStyle(.sidebar)
                
                PreviewView(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    })
                }
            }
            #else
            VHStack { isHorizontal in
                if isHorizontal {
                    ToolbarView(viewModel: viewModel, center: true)
                    
                    PreviewView(viewModel: viewModel)
                } else {
                    PreviewView(viewModel: viewModel)
                    
                    ToolbarView(viewModel: viewModel, center: false)
                        .padding(.vertical, 16)
                }
            }

            #endif
        }
        
    }
    
    
    private func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

#Preview {
    ContentView()
}
