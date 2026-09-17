// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "record_ios", path: "../.packages/record_ios-1.2.1"),
        .package(name: "permission_handler_apple", path: "../.packages/permission_handler_apple-9.4.9"),
        .package(name: "just_audio", path: "../.packages/just_audio-0.10.5"),
        .package(name: "audio_session", path: "../.packages/audio_session-0.2.3"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.13+6"),
        .package(name: "file_picker", path: "../.packages/file_picker-10.3.10"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "record-ios", package: "record_ios"),
                .product(name: "permission-handler-apple", package: "permission_handler_apple"),
                .product(name: "just-audio", package: "just_audio"),
                .product(name: "audio-session", package: "audio_session"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
