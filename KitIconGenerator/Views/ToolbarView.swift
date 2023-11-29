//
//  ToolbarView.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 29/11/2023.
//

import SwiftUI
import CrossPlatform
import ModelIO
import SceneKit
import UniformTypeIdentifiers

struct ToolbarView: View {
    
    @ObservedObject
    var viewModel: KitIconGeneratorViewModel
    
    var center: Bool
    
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
    var topContentType: TopContentType = .image
    
    @State
    var selectedInputProvider: InputProvider = .image
    
    @State
    var inputSystemSymbolName: String = ""
    
    @State
    var showChooseSystemSymbol: Bool = false
    
    @State
    var showBackground = false
    
    @StateObject
    var colorization = Colorization()
    
    let changeThread = DispatchQueue(label: "com.skillbreak.KitIconGenerator.changeThread", qos: .default, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    @ObservedObject
    var modelRotation: Vector3<Float> = .zero
    
    private let enableExperimentalRotation = false
    
    var body: some View {
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
                
                Picker("Fill", selection: $colorization.kind) {
                    ForEach(Colorization.Kind.allCases, id: \.self) { provider in
                        Text(provider.title)
                            .tag(provider)
                    }
                }
                
                switch colorization.kind {
                case .none:
                    EmptyView()
                case .color:
                    ColorPicker("Color", selection: $colorization.color)
                case .gradient:
                    GradientPicker("Gradient", gradient: $colorization.gradient)
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
            
            Toggle(isOn: $showBackground) {
                Text("Draw background")
            }
            
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
                self.iconImage = image.resize(to: CGSize(width: 256, height: 256))
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
            viewModel.kitIconRenderer.model = nil
            let backgroundColor = CPColor(self.colors.first ?? .white)
            let colorizedImage = iconImage.map { colorization.colorize(image: $0, backgroundColor: backgroundColor, context: viewModel.context) } ?? iconImage
            viewModel.kitIconRenderer.image = colorizedImage?.cgImage
            
            if let iconImage {
                self.previewImage = iconImage
            }
        }
        .onChange(of: model) { model in
            self.modelRotation.assign(.zero)
            viewModel.kitIconRenderer.image = nil
            viewModel.kitIconRenderer.model = model
            
            if let model {
                self.previewImage = renderModelToPreviewImage(model: model)
            }
        }
        .onChange(of: showBackground, perform: { newValue in
            renderScene()
        })
        .onChange(of: colors, perform: { color in
            viewModel.kitIconRenderer.colors = colors.compactMap { CPColor($0).cgColor }
        })
        .onReceive(modelRotation.objectWillChange, perform: { _ in
            viewModel.kitIconRenderer.modelRotation = modelRotation.toSIMD { value in
                (.pi / 180) * value
            }
        })
        .onReceive(viewModel.kitIconRenderer.$didChange, perform: { _ in
            self.renderScene()
        })
        .onReceive(colorization.objectDidChange, perform: { _ in
            changeThread.async {
                viewModel.kitIconRenderer.underlayColor = colorization.kind == .none
                if  topContentType == .image,
                    let iconImage,
                    let backgroundColor = self.colors.first,
                    let colorizedImage = colorization.colorize(image: iconImage, backgroundColor: CPColor(backgroundColor), context: viewModel.context) {
                    viewModel.kitIconRenderer.image = colorizedImage.cgImage
                }
            }
        })
        .onAppear {
            self.iconImage = CPImage(resource: ImageResource.kitIconGeneratorTemplate)
            self.colors = [Color(ColorResource.top), Color(ColorResource.middle), Color(ColorResource.bottom)]
        }
    }
    
    func renderScene() {
        let image = viewModel.kitIconRenderer.snapshot(size: CGSize(width: 512, height: 512), isQuick: true, renderBackground: showBackground)
        DispatchQueue.main.async {
            viewModel.renderedImage = image
        }
    }
    
    func didPressExport() {
        let image = viewModel.kitIconRenderer.snapshot(size: CGSize(width: 1024, height: 1024), isQuick: false, renderBackground: showBackground)
        
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
}
