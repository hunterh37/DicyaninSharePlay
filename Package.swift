// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DicyaninSharePlay",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "DicyaninSharePlay",
            targets: ["DicyaninSharePlay"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DicyaninSharePlay",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ]),
        .testTarget(
            name: "DicyaninSharePlayTests",
            dependencies: ["DicyaninSharePlay"]),
    ]
) 