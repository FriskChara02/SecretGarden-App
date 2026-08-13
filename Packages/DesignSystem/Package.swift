// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [
                .process("Resources/Colors.xcassets"),
                .process("Resources/Fonts")
            ]
        ),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"])
    ]
)
