// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SearchFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SearchFeature", targets: ["SearchFeature"])
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreArchitecture"),
        .package(path: "../DesignSystem"),
        .package(path: "../Repositories")
    ],
    targets: [
        .target(
            name: "SearchFeature",
            dependencies: ["CoreModels", "CoreArchitecture", "DesignSystem", "Repositories"]
        ),
        .testTarget(name: "SearchFeatureTests", dependencies: ["SearchFeature"])
    ]
)
