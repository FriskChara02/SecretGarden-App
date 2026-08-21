// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "HomeFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HomeFeature", targets: ["HomeFeature"])
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreArchitecture"),
        .package(path: "../DesignSystem"),
        .package(path: "../Repositories")
    ],
    targets: [
        .target(
            name: "HomeFeature",
            dependencies: [
                "CoreModels",
                "CoreArchitecture",
                "DesignSystem",
                "Repositories"
            ]
        ),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature"]
        )
    ]
)
