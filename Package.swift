// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cadence",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AddBikeFlowFeature", targets: ["AddBikeFlowFeature"]),
        .library(name: "AddComponentFlowFeature", targets: ["AddComponentFlowFeature"]),
        .library(name: "AddComponentMaintenanceFeature", targets: ["AddComponentMaintenanceFeature"]),
        .library(name: "AddRideFlowFeature", targets: ["AddRideFlowFeature"]),
        .library(name: "AppDelegateFeature", targets: ["AppDelegateFeature"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "AppSupportFeature", targets: ["AppSupportFeature"]),
        .library(name: "BikeClient", targets: ["BikeClient"]),
        .library(name: "BikeComponentListFeature", targets: ["BikeComponentListFeature"]),
        .library(name: "BikeComponentRowFeature", targets: ["BikeComponentRowFeature"]),
        .library(name: "BrandClient", targets: ["BrandClient"]),
        .library(name: "BrandListFeature", targets: ["BrandListFeature"]),
        .library(name: "CloudKitClient", targets: ["CloudKitClient"]),
        .library(name: "CombineHelpers", targets: ["CombineHelpers"]),
        .library(name: "ComponentClient", targets: ["ComponentClient"]),
        .library(name: "ComponentDetailFeature", targets: ["ComponentDetailFeature"]),
        .library(name: "ComponentSelectorFeature", targets: ["ComponentSelectorFeature"]),
        .library(name: "ComposableHelpers", targets: ["ComposableHelpers"]),
        .library(name: "CoreDataStack", targets: ["CoreDataStack"]),
        .library(name: "CreateComponentFeature", targets: ["CreateComponentFeature"]),
        .library(name: "DateHelpers", targets: ["DateHelpers"]),
        .library(name: "EditBikeFeature", targets: ["EditBikeFeature"]),
        .library(name: "EmailClient", targets: ["EmailClient"]),
        .library(name: "FileClient", targets: ["FileClient"]),
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        .library(name: "MaintenanceClient", targets: ["MaintenanceClient"]),
        .library(name: "MileageClient", targets: ["MileageClient"]),
        .library(name: "MileagePickerFeature", targets: ["MileagePickerFeature"]),
        .library(name: "MileageScaleFeature", targets: ["MileageScaleFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "OnboardingFeature", targets: ["OnboardingFeature"]),
        .library(name: "RideClient", targets: ["RideClient"]),
        .library(name: "SaveNewBikeFeature", targets: ["SaveNewBikeFeature"]),
        .library(name: "StoreKitClient", targets: ["StoreKitClient"]),
        .library(name: "ShareSheetClient", targets: ["ShareSheetClient"]),
        .library(name: "Style", targets: ["Style"]),
        .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),
        .library(name: "TypeSelectionFeature", targets: ["TypeSelectionFeature"]),
        .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
        .library(name: "UIUserInterfaceStyleClient", targets: ["UIUserInterfaceStyleClient"]),
        .library(name: "UserSettingsFeature", targets: ["UserSettingsFeature"]),
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        .library(name: "World", targets: ["World"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.28.1"
        ),
        .package(
            url: "https://github.com/dmytro-anokhin/core-data-model-description",
            from: "0.0.11"
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
                "BrandClient",
                "BrandListFeature",
                "ComposableHelpers",
                "Models",
                "SaveNewBikeFeature",
                "SwiftUIHelpers",
                "TypeSelectionFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AddComponentFlowFeature",
            dependencies: [
                "BrandClient",
                "BrandListFeature",
                "CreateComponentFeature",
                "ComponentClient",
                "Models",
                "TypeSelectionFeature",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AddComponentMaintenanceFeature",
            dependencies: [
                "Models",
                "World",
                "MaintenanceClient",
                "ComponentClient",
                "ComponentSelectorFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AddRideFlowFeature",
            dependencies: [
                "BikeClient",
                "ComponentClient",
                "Models",
                "RideClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AppDelegateFeature",
            dependencies: [
                "FileClient",
                "UserSettingsFeature",
                "UIUserInterfaceStyleClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "AddBikeFlowFeature",
                "AddComponentFlowFeature",
                "AddComponentMaintenanceFeature",
                "AddRideFlowFeature",
                "AppDelegateFeature",
                "AppSupportFeature",
                "BikeClient",
                "BikeComponentListFeature",
                "BikeComponentRowFeature",
                "BrandClient",
                "BrandListFeature",
                "CloudKitClient",
                "CombineHelpers",
                "ComponentClient",
                "ComponentDetailFeature",
                "ComponentSelectorFeature",
                "CoreDataStack",
                "CreateComponentFeature",
                "DateHelpers",
                "EditBikeFeature",
                "EmailClient",
                "FileClient",
                "HomeFeature",
                "MaintenanceClient",
                "MileageClient",
                "MileagePickerFeature",
                "MileageScaleFeature",
                "Models",
                "OnboardingFeature",
                "RideClient",
                "SaveNewBikeFeature",
                "StoreKitClient",
                "ShareSheetClient",
                "Style",
                "SwiftUIHelpers",
                "TypeSelectionFeature",
                "UIApplicationClient",
                "UIUserInterfaceStyleClient",
                "UserSettingsFeature",
                "UserDefaultsClient",
                "World",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "AppSupportFeature"
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
            name: "BikeComponentListFeature",
            dependencies: [
                "AddComponentFlowFeature",
                "BikeClient",
                "BrandClient",
                "ComponentClient",
                "ComponentDetailFeature",
                "MaintenanceClient",
                "EditBikeFeature",
                "Models",
                "World",
                "Style",
                "BikeComponentRowFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "BikeComponentRowFeature",
            dependencies: [
                "BikeClient",
                "MileageClient",
                "Models",
                "MileageScaleFeature",
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
                "MileageScaleFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ComponentDetailFeature",
            dependencies: [
                "AddComponentMaintenanceFeature",
                "ComponentClient",
                "MaintenanceClient",
                "MileageScaleFeature",
                "Models",
                "Style",
                "SwiftUIHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ComponentSelectorFeature",
            dependencies: [
                "Models",
                "World",
                "CoreDataStack",
                "MileageScaleFeature",
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
                "World",
                .product(name: "CoreDataModelDescription", package: "core-data-model-description")
            ],
            resources: [
                .copy("Resources/Cadence.xcdatamodeld")
            ]
        ),
        .target(
            name: "CreateComponentFeature",
            dependencies: [
                "Models",
                "BrandListFeature",
                "BrandClient",
                "ComponentClient",
                "MileagePickerFeature",
                "World",
                "SwiftUIHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(name: "DateHelpers"),
        .target(
            name: "EditBikeFeature",
            dependencies: [
                "Models",
                "BikeClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
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
            name: "HomeFeature",
            dependencies: [
                "AddBikeFlowFeature",
                "AddRideFlowFeature",
                "BikeComponentListFeature",
                "CloudKitClient",
                "Models",
                "BrandClient",
                "FileClient",
                "EmailClient",
                "BikeClient",
                "ComponentClient",
                "MaintenanceClient",
                "MileageClient",
                "MileageScaleFeature",
                "RideClient",
                "UserDefaultsClient",
                "StoreKitClient",
                "ShareSheetClient",
                "SwiftUIHelpers",
                "Style",
                "UserSettingsFeature",
                "UIApplicationClient",
                "UIUserInterfaceStyleClient",
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
            name: "MileagePickerFeature",
            dependencies: [
                "ComposableHelpers",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MileageScaleFeature",
            dependencies: [
                "Models",
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
            name: "OnboardingFeature",
            dependencies: [
                "BikeComponentRowFeature",
                "ComposableHelpers",
                "MileageScaleFeature",
                "Models",
                "BikeClient",
                "Style",
                "SwiftUIHelpers",
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
            name: "SaveNewBikeFeature",
            dependencies: [
                "Models",
                "BikeClient",
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
            name: "TypeSelectionFeature",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
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
            name: "UserSettingsFeature",
            dependencies: [
                "AppSupportFeature",
                "CloudKitClient",
                "ComposableHelpers",
                "EmailClient",
                "FileClient",
                "MileageClient",
                "Models",
                "StoreKitClient",
                "ShareSheetClient",
                "SwiftUIHelpers",
                "UserDefaultsClient",
                "UIApplicationClient",
                "UIUserInterfaceStyleClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            resources: [
                .process("Resources/")
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
        )
    ]
)

package.targets.append(contentsOf: [
    .testTarget(
        name: "AddBikeFlowFeatureTests",
        dependencies: [
            "AddBikeFlowFeature",
            "SaveNewBikeFeature",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]
    )
])
