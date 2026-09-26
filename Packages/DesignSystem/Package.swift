// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "12.8.0"))
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke")
            ],
            resources: [
                .process("Resources/Colors.xcassets"),
                .process("Resources/Assets.xcassets"),
                .process("Resources/Fonts")
            ]
        ),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"])
    ]
)
