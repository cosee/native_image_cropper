// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "native_image_cropper_macos",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "native-image-cropper-macos", targets: ["native_image_cropper_macos"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "native_image_cropper_macos",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
