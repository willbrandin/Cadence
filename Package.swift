// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cadence",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "DateHelpers", targets: ["DateHelpers"]),
        .library(name: "World", targets: ["World"]),
        .library(name: "Style", targets: ["Style"]),
        .library(name: "BrandListFeature", targets: ["BrandListFeature"]),
        .library(name: "BrandClient", targets: ["BrandClient"]),
        .library(name: "FileClient", targets: ["FileClient"]),
        .library(name: "CombineHelpers", targets: ["CombineHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.28.1")
    ],
    targets: [
        .target(name: "DateHelpers"),
        .target(name: "Models", dependencies: ["DateHelpers", "World"]),
        .target(name: "World"),
        .target(name: "Style"),
        .target(
            name: "BrandListFeature",
            dependencies: [
                "Models",
                "BrandClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "BrandClient",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            resources: [
                .copy("Resources/BikeBrandData.json")
            ]
        ),
        .target(
            name: "FileClient",
            dependencies: [
                "CombineHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(name: "CombineHelpers")
    ]
)
