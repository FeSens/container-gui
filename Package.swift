// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ContainerGUI",
    platforms: [
        .macOS(.v15),
    ],
    targets: [
        .executableTarget(
            name: "ContainerGUI",
            path: "Sources/ContainerGUI"
        ),
        .testTarget(
            name: "ContainerGUITests",
            dependencies: ["ContainerGUI"],
            path: "Tests/ContainerGUITests"
        ),
    ]
)
