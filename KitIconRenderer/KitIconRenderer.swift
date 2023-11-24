//
//  KitIconRenderer.swift
//  KitIconRenderer
//
//  Created by Eskil Gjerde Sviggum on 21/11/2023.
//

import ModelIO
import SceneKit
import SceneKit.ModelIO
import CrossPlatform

public class KitIconRenderer {

    /// The scene being rendered. Can be accessed for debugging or supplied to a SCNView
    public let scene: SCNScene
    
    private let renderer = SCNRenderer(device: nil, options: nil)
    private let boxSize: Float
    private let boxHeight: Float
    private let radius: Float
    
    private let modelPadding: Float = 0.1
    
    /// Publisher sending a signal every time a significant change occurs in the scene. Can be sinked in order to know when to take a new snapshot.
    @Published
    public private(set) var didChange: Int = 0
    
    /// The image to render on the top layer
    public var image: CGImage? {
        didSet {
            iconMaterial.diffuse.contents = iconMaterialImage
            
            if image != nil {
                iconMaterial.lightingModel = .constant
            } else {
                iconMaterial.lightingModel = .blinn
            }
            
            didChange += 1
        }
    }
    
    private var iconMaterialImage: CGImage? {
        colors.first.flatMap {
            image?.underlay(color: $0)
        }
    }
    
    /// The 3D-model to render on the top layer
    public var model: MDLAsset? {
        didSet {
            configureTopModel()
            
            didChange += 1
        }
    }
    
    /// The euler-angle rotations to apply to the model
    public var modelRotation: SIMD3<Float> = .zero {
        didSet {
            configureTopModelRotation()
            
            didChange += 1
        }
    }
    
    /// The colors to render on the layers
    public var colors: [CGColor] = [CPColor.white.cgColor, CPColor.systemCyan.cgColor, CPColor.systemTeal.cgColor] {
        didSet {
            layerNodes.enumerated().forEach { (i, node) in
                guard colors.indices.contains(i) else {
                    return
                }
                
                let color = colors[i]
                
                node.geometry?.materials.last?.diffuse.contents = color
            }
            
            if let iconMaterialImage {
                iconMaterial.diffuse.contents = iconMaterialImage
            } else {
                iconMaterial.diffuse.contents = colors.first
            }
            
            didChange += 1
        }
    }
    
    private var layerNodes = [SCNNode]()
    
    private let frontLightNode: SCNNode = {
        let light = SCNLight()
        light.type = .omni
        light.color = CPColor.white
        light.intensity = 800
        light.categoryBitMask = ~(1 << 1)
        let lightNode = SCNNode()
        lightNode.light = light
        return lightNode
    }()
    
    private let leftLightNode: SCNNode = {
        let light = SCNLight()
        light.type = .omni
        light.color = CPColor.white
        light.intensity = 1000
        light.categoryBitMask = ~(1 << 1)
        let lightNode = SCNNode()
        lightNode.light = light
        return lightNode
    }()
    
    private let closeLeftLightNode: SCNNode = {
        let light = SCNLight()
        light.type = .omni
        light.color = CPColor.white
        light.intensity = 500
        light.categoryBitMask = ~(1 << 1)
        let lightNode = SCNNode()
        lightNode.light = light
        return lightNode
    }()
    
    private let topLightNode: SCNNode = {
        let light = SCNLight()
        light.type = .omni
        light.color = CPColor.white
        light.intensity = 900
        light.categoryBitMask = ~(1 << 1)
        let lightNode = SCNNode()
        lightNode.light = light
        return lightNode
    }()
    
    private let modelLightNode: SCNNode = {
        let light = SCNLight()
        light.type = .omni
        light.color = CPColor.white
        light.intensity = 1000
        light.categoryBitMask = (1 << 1)
        light.castsShadow = false
        let lightNode = SCNNode()
        lightNode.light = light
        return lightNode
    }()
    
    private let cameraNode: SCNNode = {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(-2.135485, 3.542209, 3.097715)
        cameraNode.eulerAngles = SCNVector3Make(-.pi / 4, -.pi / 4, 0)
        return cameraNode
    }()
    
    private let iconMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, -1, 1)
        material.diffuse.wrapT = .repeat
        material.diffuse.wrapS = .repeat
        material.lightingModel = .constant
        return material
    }()
    
    private let modelMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CPColor.white
        material.lightingModel = .blinn
        return material
    }()
    
    public init(scene: SCNScene, boxSize: Float, boxHeight: Float, radius: Float, image: CGImage?) {
        self.scene = scene
        self.boxSize = boxSize
        self.boxHeight = boxHeight
        self.radius = radius
        self.image = image
        
        renderer.scene = scene
    }
    
    public convenience init(image: CGImage? = nil) {
        let boxSize: Float = 1
        let boxHeight = boxSize / (3 * 2)
        let radius = boxSize * 0.22
        
        self.init(scene: SCNScene(), boxSize: boxSize, boxHeight: boxHeight, radius: radius, image: image)
        
        setupScene()
    }
    
    private func setupScene() {
        
        iconMaterial.diffuse.contents = image
        configureTopModel()
        
        let roundedSquareShape = CPBezierPath.roundedRectangle(rect: CGRect(origin: .zero, size: CGSize(width: CGFloat(boxSize), height: CGFloat(boxSize))), radius: CGFloat(radius))
        roundedSquareShape.flatness = 1 / 1000
        
        let yOffset = -(3 * boxHeight) / 2
        
        let layer1Node = createLayerNode(path: roundedSquareShape, color: .systemCyan)
        layer1Node.simdPosition = SIMD3(x: 0, y: yOffset, z: 0)
        scene.rootNode.addChildNode(layer1Node)
        
        let layer2Node = createLayerNode(path: roundedSquareShape, color: .systemTeal)
        layer2Node.simdPosition = SIMD3(x: 0, y: boxHeight + yOffset, z: 0)
        scene.rootNode.addChildNode(layer2Node)
        
        let layer3Node = createLayerNode(path: roundedSquareShape, color: .white)
        layer3Node.simdPosition = SIMD3(x: 0, y: 2 * boxHeight + yOffset, z: 0)
        let remainingMaterial = layer3Node.geometry?.firstMaterial ?? SCNMaterial()
        layer3Node.geometry?.materials = [iconMaterial, iconMaterial, remainingMaterial]
        scene.rootNode.addChildNode(layer3Node)
        
        self.layerNodes = [layer3Node, layer2Node, layer1Node]
        
        // Front light
        scene.rootNode.addChildNode(frontLightNode)
        frontLightNode.position = SCNVector3(0.2, boxHeight + yOffset, 2.3)
        
        // Left light
        scene.rootNode.addChildNode(leftLightNode)
        leftLightNode.position = SCNVector3(-3, boxHeight + yOffset, 0)
        
        // Left close light
        scene.rootNode.addChildNode(closeLeftLightNode)
        closeLeftLightNode.position = SCNVector3(-0.2, boxHeight + yOffset, 0.8)
        
        // Top light
        scene.rootNode.addChildNode(topLightNode)
        topLightNode.position = SCNVector3(0.5, 2, 0.5)
        
        // Model light
        scene.rootNode.addChildNode(modelLightNode)
        modelLightNode.position = SCNVector3(0, 1.5, 1)

        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func createLayerNode(path: CPBezierPath, color: CPColor) -> SCNNode {
        let geometry = SCNShape(path: path, extrusionDepth: CGFloat(boxHeight))
        geometry.chamferRadius = 0
        geometry.materials.first?.diffuse.contents = color
        geometry.firstMaterial?.lightingModel = .blinn
        let node = SCNNode(geometry: geometry)
        node.eulerAngles.x = .pi / 2
        
        return node
    }
    
    private func configureTopModel() {
        removeTopModel()
        
        guard 
            let model,
            let attachment = self.layerNodes.first
        else {
            return
        }
        
        let scene = SCNScene(mdlAsset: model)
        let node = scene.rootNode
        
        var childNodes = node.childNodes
        
        while !childNodes.isEmpty {
            let child = childNodes.removeLast()
            
            if child.light != nil {
                child.removeFromParentNode()
                continue
            }
            
            if child.camera != nil {
                child.removeFromParentNode()
                continue
            }
            
            childNodes += child.childNodes
            
            child.geometry?.materials = [modelMaterial]
        }
        
        let flattenedNode = node.flattenedClone()
        let (minBox, maxBox) = node.boundingBox
        
        flattenedNode.eulerAngles.x = -.pi / 2
        
        flattenedNode.position = SCNVector3(-Float(minBox.x), -Float(minBox.z), 0)
        
        flattenedNode.categoryBitMask = 1 << 1
        let rotationNode = SCNNode()
//        rotationNode.position = SCNVector3(0.5, 0.5, 0)
        rotationNode.addChildNode(flattenedNode)
        
        let containerNode = SCNNode()
        containerNode.addChildNode(rotationNode)
        containerNode.name = "top_model"
        configureTopModelFill(minBox: minBox, maxBox: maxBox, node: containerNode)
        attachment.addChildNode(containerNode)
    }
    
    private func configureTopModelFill(minBox: SCNVector3, maxBox: SCNVector3, node: SCNNode) {
        let modelSize = SIMD2(Float(maxBox.x - minBox.x), Float(maxBox.z - minBox.z))
        let greaterDimension = modelSize.max()
        let scale = Float(boxSize - 2 * modelPadding) / greaterDimension
        
        //scale * (-Float(minBox.z)) + modelPadding
        node.position = SCNVector3(modelPadding, modelPadding, Float(-boxHeight) / 2)
        node.scale = SCNVector3(scale, scale, scale)
    }
    
    private func configureTopModelRotation() {
        guard
            let attachment = self.layerNodes.first,
            let containerNode = attachment.childNode(withName: "top_model", recursively: false),
            let rotationNode = containerNode.childNodes.first
        else {
            return
        }
        
        rotationNode.simdEulerAngles = modelRotation
        
//        let (minBox, maxBox) = containerNode.boundingBox
        
//        configureTopModelFill(minBox: minBox, maxBox: maxBox, node: containerNode)
    }
    
    private func removeTopModel() {
        guard let attachment = self.layerNodes.first else {
            return
        }
        
        attachment.childNodes
            .filter { $0.name == "top_model" }
            .forEach { $0.removeFromParentNode() }
    }
    
    /// Renders the specified image, model and colors into an image
    public func snapshot(size: CGSize) -> CPImage {
        renderer.snapshot(atTime: 0, with: size, antialiasingMode: .multisampling4X)
    }
    
}
