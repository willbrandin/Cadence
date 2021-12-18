// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cadence",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "BikeClient", targets: ["BikeClient"]),
        .library(name: "ComponentClient", targets: ["ComponentClient"]),
        .library(name: "CoreDataStack", targets: ["CoreDataStack"]),
        .library(name: "MaintenanceClient", targets: ["MaintenanceClient"]),
        .library(name: "ManagedObjects", targets: ["ManagedObjects"]),
        .library(name: "MileageClient", targets: ["MileageClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "RideClient", targets: ["RideClient"]),
        .library(name: "DateHelpers", targets: ["DateHelpers"]),
        .library(name: "World", targets: ["World"]),
        .library(name: "Style", targets: ["Style"]),
        .library(name: "BrandListFeature", targets: ["BrandListFeature"]),
        .library(name: "BrandClient", targets: ["BrandClient"]),
        .library(name: "FileClient", targets: ["FileClient"]),
        .library(name: "CombineHelpers", targets: ["CombineHelpers"]),
        .library(name: "EmailClient", targets: ["EmailClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.28.1")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "BikeClient",
                "BrandClient",
                "BrandListFeature",
                "ComponentClient",
                "CombineHelpers",
                "CoreDataStack",
                "MaintenanceClient",
                "MileageClient",
                "RideClient",
                "DateHelpers",
                "EmailClient",
                "FileClient",
                "ManagedObjects",
                "Models",
                "Style",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "BikeClient",
            dependencies: [
                "Models",
                "World",
                "ManagedObjects",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ComponentClient",
            dependencies: [
                "Models",
                "World",
                "ManagedObjects",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "CoreDataStack",
            dependencies: []
        ),
        .target(name: "DateHelpers"),
        .target(
            name: "MaintenanceClient",
            dependencies: [
                "Models",
                "World",
                "ManagedObjects",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ManagedObjects",
            dependencies: [
                "Models",
                "World"
            ],
            resources: [
                .copy("Resources/Cadence.xcdatamodeld")
            ]
        ),
        .target(
            name: "MileageClient",
            dependencies: [
                "Models",
                "World",
                "ManagedObjects",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                "DateHelpers",
                "World"
            ]
        ),
        .target(
            name: "RideClient",
            dependencies: [
                "Models",
                "World",
                "ManagedObjects",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        
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
        .target(name: "CombineHelpers"),
        .target(
            name: "EmailClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "World",
            dependencies: [
                "CoreDataStack"
            ]
        )
    ]
)
