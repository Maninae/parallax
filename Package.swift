// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "parallax",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Parallax", targets: ["parallax"])
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/imsg.git", branch: "main"),
        .package(url: "https://github.com/mattt/ollama-swift.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "parallax",
            dependencies: [
                .product(name: "IMsgCore", package: "imsg"),
                .product(name: "Ollama", package: "ollama-swift")
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
