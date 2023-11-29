//
//  GradientEditorView.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import SwiftUI
import CrossPlatform

struct GradientEditorView: View {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var gradient: LinearGradientDescription
    
    @State
    private var color0: Color = .white
    
    @State
    private var color1: Color = .black
    
    @State
    private var point0X: CGFloat = 0
    
    @State
    private var point0Y: CGFloat = 0
    
    @State
    private var point1X: CGFloat = 1
    
    @State
    private var point1Y: CGFloat = 1
    
    let stopsContainerSize: CGFloat = 100
    
    var body: some View {
        VStack {
            HStack {
                Text("Edit gradient")
                    .font(.title)
                    .bold()
                Spacer()
            }
            
            Divider()
            
            HStack {
                Text("Points")
                Spacer()
            }
            
            ZStack {
                Circle()
                    .fill()
                    .foregroundStyle(color0)
                    .frame(width: 25, height: 25)
                    .position(CGPoint(x: point0X * stopsContainerSize, y: point0Y * stopsContainerSize))
                    .gesture(DragGesture().onChanged({ value in
                        self.point0X = clamp(value.location.x / stopsContainerSize, 0, 1)
                        self.point0Y = clamp(value.location.y / stopsContainerSize, 0, 1)
                    }))
                
                Circle()
                    .fill()
                    .foregroundStyle(color1)
                    .frame(width: 25, height: 25)
                    .position(CGPoint(x: point1X * stopsContainerSize, y: point1Y * stopsContainerSize))
                    .gesture(DragGesture().onChanged({ value in
                        self.point1X = clamp(value.location.x / stopsContainerSize, 0, 1)
                        self.point1Y = clamp(value.location.y / stopsContainerSize, 0, 1)
                    }))
            }
            .background(
                LinearGradient(colors: [color0, color1], startPoint: UnitPoint(x: point0X, y: point0Y), endPoint: UnitPoint(x: point1X, y: point1Y))
            )
            .frame(width: stopsContainerSize, height: stopsContainerSize)
            
            
            HStack {
                Text("Colors")
                Spacer()
            }
            
            HStack {
                ColorPicker("", selection: $color0)
                
                Spacer()
                
                Button {
                    didPressSwitchColors()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                }
                
                Spacer()
                
                ColorPicker("", selection: $color1)
            }.frame(minWidth: 100, maxWidth: 200)
            
            Divider()
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .buttonStyle(BorderedButtonStyle())
                
                Spacer()
                
                Button {
                    guard 
                        let color0 = color0.cgColor,
                        let color1 = color1.cgColor
                    else {
                        dismiss()
                        return
                    }
                    
                    self.gradient = LinearGradientDescription(color0: color0, color1: color1, point0: CGPoint(x: point0X, y: point0Y), point1: CGPoint(x: point1X, y: point1Y))
                    dismiss()
                } label: {
                    Text("Done")
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
                 
        }
        .padding(16)
        .background(Color(CPColor.systemGroupedBackground))
        .onAppear(perform: {
            color0 = Color(cgColor: gradient.color0)
            color1 = Color(cgColor: gradient.color1)
            point0X = gradient.point0.x
            point0Y = gradient.point0.y
            point1X = gradient.point1.x
            point1Y = gradient.point1.y
        })
    }
    
    private func didPressSwitchColors() {
        let temp = color1
        color1 = color0
        color0 = temp
    }
}

#Preview {
    @State
    var gradient = LinearGradientDescription(color0: .black, color1: .white, point0: .zero, point1: CGPoint(x: 1, y: 1))
    
    return GradientEditorView(gradient: $gradient)
}
