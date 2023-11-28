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

enum TopContentType {
    case image
    case model
}

enum InputProvider: CaseIterable {
    case image
    case systemSymbol
    
    var title: String {
        switch self {
        case .image:
            "Image"
        case .systemSymbol:
            "System symbol"
        }
    }
}

struct ContentView: View {
    let kitIconRenderer = KitIconRenderer()
    
    @State
    var exportURL: URL?
    
    @State
    var iconURL: URL?
    
    @State
    var iconImage: CPImage?
    
    @State
    var previewImage: CPImage?
    
    @State
    var model: MDLAsset?
    
    @State
    var showImportIconSheet = false
    
    @State
    var colors: [Color] = [.white, .white, .white]
    
    @State
    var renderedImage: CPImage?
    
    @State
    var topContentType: TopContentType = .image
    
    @State
    var selectedInputProvider: InputProvider = .image
    
    @State
    var inputSystemSymbolName: String = ""
    
    @State
    var showChooseSystemSymbol: Bool = false
    
    @ObservedObject
    var modelRotation: Vector3<Float> = .zero
    
    private let enableExperimentalRotation = false
    
    var body: some View {
        
        Group {
        #if os(macOS)
        NavigationView {
            toolbarView(center: true)
                .listStyle(.sidebar)
            
            previewView()
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
                toolbarView(center: true)
                
                previewView()
            } else {
                previewView()
                
                toolbarView(center: false)
                    .padding(.vertical, 16)
            }
        }

        #endif
        }
        .sheet(item: $exportURL) { url in
            #if canImport(UIKit)
            DocumentExporter(exporting: url)
            #else
            EmptyView()
            #endif
        }
        .sheet(isPresented: $showImportIconSheet) {
            #if canImport(UIKit)
            DocumentPicker(url: $iconURL, contentTypes: [.image, .threeDContent])
            #else
            EmptyView()
            #endif
        }
        .sheet(isPresented: $showChooseSystemSymbol, content: {
            SystemSymbolPickerView(selectedSymbolName: $inputSystemSymbolName)
        })
        .onChange(of: inputSystemSymbolName) { symbolName in
            if let image = CPImage(systemName: symbolName) {
                self.model = nil
                self.iconImage = image
                self.topContentType = .image
            }
        }
        .onChange(of: iconURL) { url in
            guard
                let url,
                let contentType = UTType(filenameExtension: url.pathExtension)
            else {
                return
            }
            
            let matchSet = Set([contentType]).union(contentType.supertypes)
            
            switch matchSet {
            case let match where match.contains(.image):
                let image = CPImage(contentsOfFile: url.path)
                self.model = nil
                self.iconImage = image
                self.topContentType = .image
            case let match where match.contains(.threeDContent):
                self.iconImage = nil
                self.model = MDLAsset(url: url)
                self.topContentType = .model
            default:
                print("Unhandled content type: \(contentType)")
                assertionFailure()
            }
        }
        .onChange(of: iconImage) { iconImage in
            kitIconRenderer.model = nil
            kitIconRenderer.image = iconImage?.cgImage
            
            if let iconImage {
                self.previewImage = iconImage
            }
        }
        .onChange(of: model) { model in
            self.modelRotation.assign(.zero)
            kitIconRenderer.image = nil
            kitIconRenderer.model = model
            
            if let model {
                self.previewImage = renderModelToPreviewImage(model: model)
            }
        }
        .onChange(of: colors, perform: { color in
            kitIconRenderer.colors = colors.compactMap { CPColor($0).cgColor }
        })
        .onReceive(modelRotation.objectWillChange, perform: { _ in
            kitIconRenderer.modelRotation = modelRotation.toSIMD { value in
                (.pi / 180) * value
            }
        })
        .onReceive(kitIconRenderer.$didChange, perform: { _ in
            self.renderScene()
        })
        .onAppear {
            self.iconImage = CPImage(resource: ImageResource.kitIconGeneratorTemplate)
            self.colors = [Color(ColorResource.top), Color(ColorResource.middle), Color(ColorResource.bottom)]
        }
    }
    
    @ViewBuilder
    private func toolbarView(center: Bool) -> some View {
        VStack(spacing: 16) {
            if center {
                Spacer()
            }
            
            VStack {
                if let previewImage {
                    Image(cpImage: previewImage)
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 128, height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke()
                                .foregroundStyle(Color(CPColor.tertiaryLabel))
                        )
                }
                
                Picker("Input type", selection: $selectedInputProvider) {
                    ForEach(InputProvider.allCases, id: \.self) { provider in
                        Text(provider.title)
                            .tag(provider)
                    }
                }
                
                switch selectedInputProvider {
                case .image:
                    Button {
                        didPressImportIcon()
                    } label: {
                        Text("Choose image or 3D-model")
                    }.buttonStyle(BorderedButtonStyle())
                case .systemSymbol:
                    VStack {
                        TextField("Symbol name", text: $inputSystemSymbolName)
                        Button {
                            didPressSelectSystemIcon()
                        } label: {
                            Text("Choose system icon")
                        }.buttonStyle(BorderedButtonStyle())
                    }
                }
                
            }
            
            if enableExperimentalRotation && topContentType == .model {
                VStack {
                    HStack {
                        Text("Rotation (deg)")
                        Spacer()
                    }
                    
                    HStack {
                        HStack {
                            TextField("X", text: $modelRotation.xText)
                            Stepper("", value: $modelRotation.x)
                        }
                        HStack {
                            TextField("Y", text: $modelRotation.yText)
                            Stepper("", value: $modelRotation.y)
                        }
                        HStack {
                            TextField("Z", text: $modelRotation.zText)
                            Stepper("", value: $modelRotation.z)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Top color")
                    Spacer()
                    ColorPicker("", selection: $colors[0])
                }
                
                HStack {
                    Text("Middle color")
                    Spacer()
                    ColorPicker("", selection: $colors[1])
                }
                
                HStack {
                    Text("Bottom color")
                    Spacer()
                    ColorPicker("", selection: $colors[2])
                }
            }.frame(maxWidth: 250)
            
            Button {
                didPressExport()
            } label: {
                Text("Export image")
            }.buttonStyle(BorderedProminentButtonStyle())
            
            if center {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .frame(minWidth: 250)
    }
    
    @ViewBuilder
    private func previewView() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                #if DEBUG
                // In order to inspect the SCNScene with View Hierarchy Capture
                SceneView(scene: kitIconRenderer.scene)
                    .frame(width: 1, height: 1)
                    .opacity(0)
                #endif
                
                if let renderedImage {
                    Image(cpImage: renderedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 500, maxHeight: 500)
                }
                
                Spacer()
            }
            Spacer()
        }
        .background(Color(CPColor.systemGroupedBackground))
    }
    
    func renderScene() {
        let image = kitIconRenderer.snapshot(size: CGSize(width: 1024, height: 1024))
        self.renderedImage = image
    }
    
    func didPressExport() {
        let image = kitIconRenderer.snapshot(size: CGSize(width: 1024, height: 1024))
        
        guard let data = image.pngData() else {
            assertionFailure()
            return
        }
        
        export(data: data, withName: "KitIcon.png")
        
    }
    
    func didPressImportIcon() {
        importFile(toBinding: $iconURL)
    }
    
    func didPressSelectSystemIcon() {
        showChooseSystemSymbol = true
    }
    
    private func renderModelToPreviewImage(model: MDLAsset) -> CPImage {
        let scene = SCNScene(mdlAsset: model)
        scene.background.contents = MDLSkyCubeTexture(name: "sky", channelEncoding: .float16, textureDimensions: vector_int2(128, 128), turbidity: 0, sunElevation: 1.5, upperAtmosphereScattering: 0.5, groundAlbedo: 0.5)
        let renderer = SCNRenderer(device: nil, options: nil)
        renderer.scene = scene
        renderer.autoenablesDefaultLighting = true
        let image = renderer.snapshot(atTime: 0, with: CGSize(width: 512, height: 512), antialiasingMode: .multisampling2X)
        return image
    }
    
    #if canImport(UIKit)
    private func importFile(toBinding binding: Binding<URL?>) {
        self.showImportIconSheet = true
    }
    #elseif canImport(Cocoa)
    private func importFile(toBinding binding: Binding<URL?>) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose icon image"
        openPanel.allowedContentTypes = [.image, .threeDContent]
        openPanel.level = .modalPanel
        openPanel.begin { response in
            guard
                response == .OK,
                let url = openPanel.url
            else {
                return
            }
            
            binding.wrappedValue = url
        }
    }
    #endif
    
    #if canImport(UIKit)
    private func export(data: Data, withName name: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let url = documentDirectory.appendingPathComponent(name)
        
        do {
            try data.write(to: url)
            self.exportURL = url
        } catch {
            print("Could not write data:", error)
        }
    }
    #elseif canImport(Cocoa)
    private func export(data: Data, withName name: String) {
        let savePanel = NSSavePanel()
        savePanel.title = "Export image"
        savePanel.nameFieldStringValue = name
        savePanel.allowedContentTypes = [.png]
        savePanel.level = .modalPanel
        savePanel.begin { response in
            guard 
                response == .OK,
                let url = savePanel.url
            else {
                return
            }
            
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                print("Could not write data:", error)
            }
        }
    }
    #endif
    
    private func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

#Preview {
    ContentView()
}
