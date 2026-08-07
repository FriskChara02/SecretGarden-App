// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "CoreModels",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "CoreModels", targets: ["CoreModels"])
    ],
    targets: [
        .target(name: "CoreModels"),
        .testTarget(name: "CoreModelsTests", dependencies: ["CoreModels"])
    ]
)
