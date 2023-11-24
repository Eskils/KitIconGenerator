<img src="../Documentation/KitIconRendererIconScaled.png" alt="KitIconRenderer Icon" width="128px">

# KitIconRenderer

Icon scene rendering.

Provide image, model and colors and take a snapshot to produce an image.

### Properties
|Name|Type|Default (if settable) |Description|
|----|----|-------|-----------|
|scene|`SCNScene`|N/A| The scene being rendered. Can be accessed for debugging or supplied to a SCNView|
|$didChange|`Published<Int>.Publisher`|0|Publisher sending a signal every time a significant change occurs in the scene. Can be sinked in order to know when to take a new snapshot|
|image|`CGImage?`|nil|The image to render on the top layer|
|model|`MDLAsset?`|nil|The 3D-model to render on the top layer|
|modelRotation|SIMD3<Float>|.zero| The euler-angle rotations to apply to the model|
|colors| [CGColor] | [white, systemCyan, systemTeal] | The colors to render on the layers|

### Methods
```swift
/// Renders the specified image, model and colors into an image
public func snapshot(size: CGSize) -> CPImage
```

## Contributing

Contributions are welcome and encouraged. Feel free to check out the project, submit issues and code patches.