// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "CoreArchitecture",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CoreArchitecture", targets: ["CoreArchitecture"])
    ],
    dependencies: [
        .package(path: "../CoreModels")
    ],
    targets: [
        .target(
            name: "CoreArchitecture",
            dependencies: ["CoreModels"]
        ),
        .testTarget(
            name: "CoreArchitectureTests",
            dependencies: ["CoreArchitecture"]
        )
    ]
)
