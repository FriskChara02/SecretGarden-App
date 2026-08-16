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
        .package(url: "https://github.com/hmlongco/Factory", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "Repositories",
            dependencies: [
                "CoreModels",
                "CoreArchitecture",
                "CoreNetworking",
                "CoreStorage",
                .product(name: "FactoryKit", package: "Factory")
            ]
        ),
        .testTarget(
            name: "RepositoriesTests",
            dependencies: ["Repositories"]
        )
    ]
)
