<img src="Documentation/KitIconGeneratorIcon.png" alt="KitIconGenerator Icon" width="128px">

#  KitIconGenerator

Generate framework icons in Apple style.

## Usage

![Screenshot of the KitIconGenerator application](Documentation/ApplicationScreenshotLight.png#gh-light-mode-only)
![Screenshot of the KitIconGenerator application](Documentation/ApplicationScreenshotDark.png#gh-dark-mode-only)

- Download and open the latest release from [Releases](https://github.com/Eskils/KitIconGenerator/releases/latest)
- Choose your framework’s icon (3D-models are also supported)
- Choose the colors you want to use
- Export image

## Project Organization

This application is written in Swift using SwiftUI for layout and SceneKit for rendering. 

The app is built cross-platform for iOS and macOS, and uses the `CrossPlatform` helper library to provide typealiases and extensions for common UI elements. Anything prefixed with `CP` originates from this library.

Implementation of rendering the scene can be found in the `KitIconRenderer` library.

## Contributing to KitIconGenerator

Contributions are welcome and encouraged. Feel free to check out the project, submit issues and code patches.


