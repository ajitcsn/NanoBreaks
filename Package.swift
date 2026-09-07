// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NanoBreaks",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "NanoBreaksCore", targets: ["NanoBreaksCore"]),
        .executable(name: "NanoBreaks", targets: ["NanoBreaksApp"]),
        .executable(name: "NanoBreaksChecks", targets: ["NanoBreaksChecks"])
    ],
    targets: [
        .target(name: "NanoBreaksCore"),
        .executableTarget(
            name: "NanoBreaksApp",
            dependencies: ["NanoBreaksCore"]
        ),
        .executableTarget(
            name: "NanoBreaksChecks",
            dependencies: ["NanoBreaksCore"]
        )
    ]
)
