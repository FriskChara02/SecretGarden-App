// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "AuthFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AuthFeature", targets: ["AuthFeature"])
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreArchitecture"),
        .package(path: "../DesignSystem"),
        .package(path: "../Repositories"),
        .package(url: "https://github.com/hmlongco/Factory", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "AuthFeature",
            dependencies: [
                "CoreModels",
                "CoreArchitecture",
                "DesignSystem",
                "Repositories",
                .product(name: "FactoryKit", package: "Factory")
            ]
        ),
        .testTarget(
            name: "AuthFeatureTests",
            dependencies: ["AuthFeature"]
        )
    ]
)
