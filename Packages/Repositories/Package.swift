// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Repositories",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Repositories", targets: ["Repositories"])
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreArchitecture"),
        .package(path: "../CoreNetworking"),
        .package(path: "../CoreStorage"),
    ],
    targets: [
        .target(
            name: "Repositories",
            dependencies: [
                "CoreModels",
                "CoreArchitecture",
                "CoreNetworking",
                "CoreStorage",
            ]
        ),
        .testTarget(
            name: "RepositoriesTests",
            dependencies: ["Repositories"]
        )
    ]
)
