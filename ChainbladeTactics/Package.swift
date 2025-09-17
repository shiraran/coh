// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ChainbladeTactics",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ChainbladeTactics", targets: ["ChainbladeCore"])
    ],
    targets: [
        .target(
            name: "ChainbladeCore",
            path: "../Sources",
            exclude: ["App"],
            resources: [
                .process("../Assets")
            ]
        ),
        .testTarget(
            name: "ChainbladeCoreTests",
            dependencies: ["ChainbladeCore"],
            path: "../Tests"
        )
    ]
)
