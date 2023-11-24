//
//  VHStack.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 23/11/2023.
//

import SwiftUI

struct VHStack<Content: View>: View {
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    var spacing: CGFloat?
    
    let content: (_ isHorizontal: Bool) -> Content
    
    init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping (_ isHorizontal: Bool) -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                HStack(spacing: spacing) {
                    content(true)
                }
            } else {
                VStack(spacing: spacing) {
                    content(false)
                }
            }
        }
    }
}
