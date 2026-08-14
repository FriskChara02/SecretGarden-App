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
        .package(path: "../CoreArchitecture")
    ],
    targets: [
        .target(
            name: "CoreNetworking",
            dependencies: ["CoreModels", "CoreArchitecture"]
        ),
        .testTarget(name: "CoreNetworkingTests", dependencies: ["CoreNetworking"])
    ]
)
