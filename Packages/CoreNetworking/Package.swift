// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "CoreNetworking",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "CoreNetworking", targets: ["CoreNetworking"])
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreArchitecture"),
        .package(path: "../CoreStorage")
    ],
    targets: [
        .target(
            name: "CoreNetworking",
            dependencies: ["CoreModels", "CoreArchitecture", "CoreStorage"]
        ),
        .testTarget(name: "CoreNetworkingTests", dependencies: ["CoreNetworking"])
    ]
)
