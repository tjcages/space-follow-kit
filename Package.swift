// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SpaceFollowKit",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SpaceFollowKit",
            targets: ["SpaceFollowKit"]
        )
    ],
    targets: [
        .target(
            name: "SpaceFollowKit"
        )
    ]
)
