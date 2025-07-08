// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "native_image_cropper_ios",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "native-image-cropper-ios", targets: ["native_image_cropper_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "native_image_cropper_ios",
            dependencies: []
        )
    ]
)
