// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cadence",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AddBikeFlowFeature", targets: ["AddBikeFlowFeature"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "BikeClient", targets: ["BikeClient"]),
        .library(name: "BikeTypeSelectionFeature", targets: ["BikeTypeSelectionFeature"]),
        .library(name: "BrandClient", targets: ["BrandClient"]),
        .library(name: "BrandListFeature", targets: ["BrandListFeature"]),
        .library(name: "CloudKitClient", targets: ["CloudKitClient"]),
        .library(name: "CombineHelpers", targets: ["CombineHelpers"]),
        .library(name: "ComponentClient", targets: ["ComponentClient"]),
        .library(name: "ComposableHelpers", targets: ["ComposableHelpers"]),
        .library(name: "CoreDataStack", targets: ["CoreDataStack"]),
        .library(name: "DateHelpers", targets: ["DateHelpers"]),
        .library(name: "EmailClient", targets: ["EmailClient"]),
        .library(name: "FileClient", targets: ["FileClient"]),
        .library(name: "MaintenanceClient", targets: ["MaintenanceClient"]),
        .library(name: "MileageClient", targets: ["MileageClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "SaveNewBikeFeature", targets: ["SaveNewBikeFeature"]),
        .library(name: "RideClient", targets: ["RideClient"]),
        .library(name: "StoreKitClient", targets: ["StoreKitClient"]),
        .library(name: "ShareSheetClient", targets: ["ShareSheetClient"]),
        .library(name: "Style", targets: ["Style"]),
        .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),
        .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
        .library(name: "UIUserInterfaceStyleClient", targets: ["UIUserInterfaceStyleClient"]),
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        .library(name: "World", targets: ["World"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.28.1"
        ),
        .package(
            name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        )
    ],
    targets: [
        .target(
            name: "AddBikeFlowFeature",
            dependencies: [
                "BikeClient",
                "BikeTypeSelectionFeature",
                "BrandClient",
                "BrandListFeature",
                "ComposableHelpers",
                "Models",
                "SaveNewBikeFeature",
                "SwiftUIHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "AddBikeFlowFeature",
                "BikeClient",
                "BikeTypeSelectionFeature",
                "BrandClient",
                "BrandListFeature",
                "CloudKitClient",
                "CombineHelpers",
                "ComponentClient",
                "CoreDataStack",
                "DateHelpers",
                "EmailClient",
                "FileClient",
                "MaintenanceClient",
                "MileageClient",
                "Models",
                "SaveNewBikeFeature",
                "RideClient",
                "StoreKitClient",
                "ShareSheetClient",
                "Style",
                "SwiftUIHelpers",
                "UIApplicationClient",
                "UIUserInterfaceStyleClient",
                "UserDefaultsClient",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "BikeClient",
            dependencies: [
                "Models",
                "World",
                "CoreDataStack",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "BikeTypeSelectionFeature",
            dependencies: [
                "Models",
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
            name: "BrandListFeature",
            dependencies: [
                "Models",
                "BrandClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "CloudKitClient",
            dependencies: [
                "CoreDataStack",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(name: "CombineHelpers"),
        .target(
            name: "ComponentClient",
            dependencies: [
                "Models",
                "World",
                "CoreDataStack",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ComposableHelpers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "CoreDataStack",
            dependencies: [
                "Models",
                "World"
            ],
            resources: [
                .copy("Resources/Cadence.xcdatamodeld")
            ]
        ),
        .target(name: "DateHelpers"),
        .target(
            name: "EmailClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "FileClient",
            dependencies: [
                "CombineHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MaintenanceClient",
            dependencies: [
                "Models",
                "World",
                "CoreDataStack",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MileageClient",
            dependencies: [
                "Models",
                "World",
                "CoreDataStack",
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
            name: "SaveNewBikeFeature",
            dependencies: [
                "Models",
                "BikeClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "RideClient",
            dependencies: [
                "Models",
                "World",
                "CoreDataStack",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ShareSheetClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "StoreKitClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(name: "Style"),
        .target(name: "SwiftUIHelpers"),
        .target(
            name: "UIApplicationClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "UIUserInterfaceStyleClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "UserDefaultsClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "World"
        ),
        .testTarget(
            name: "AddBikeFlowFeatureTests",
            dependencies: [
                "AddBikeFlowFeature",
                "SaveNewBikeFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
