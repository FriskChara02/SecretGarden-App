// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SocialFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SocialFeature", targets: ["SocialFeature"])
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreArchitecture"),
        .package(path: "../DesignSystem"),
        .package(path: "../Repositories")
    ],
    targets: [
        .target(
            name: "SocialFeature",
            dependencies: ["CoreModels", "CoreArchitecture", "DesignSystem", "Repositories"]
        ),
        .testTarget(name: "SocialFeatureTests", dependencies: ["SocialFeature"])
    ]
)
