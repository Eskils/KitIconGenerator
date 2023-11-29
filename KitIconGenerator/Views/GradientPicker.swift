//
//  GradientPicker.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import SwiftUI

struct GradientPicker: View {
    
    let titleKey: LocalizedStringKey
    
    @Binding
    var gradient: LinearGradientDescription
    
    @State
    private var showGradientEditorView = false
    
    init(_ titleKey: LocalizedStringKey, gradient: Binding<LinearGradientDescription>) {
        self.titleKey = titleKey
        self._gradient = gradient
    }
    
    var body: some View {
        
        HStack {
            Text(titleKey)
            
            Button {
                didPressEditGradient()
            } label: {
                LinearGradient(colors: [Color(cgColor: gradient.color0), Color(cgColor: gradient.color1)], startPoint: UnitPoint(x: gradient.point0.x, y: gradient.point0.y), endPoint: UnitPoint(x: gradient.point1.x, y: gradient.point1.y))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.horizontal, -8)
                    .padding(2)
            }
            .frame(width: 44, height: 30)
        }
        .sheet(isPresented: $showGradientEditorView, content: {
            GradientEditorView(gradient: $gradient)
        })
        
    }
    
    private func didPressEditGradient() {
        showGradientEditorView = true
    }
    
}
