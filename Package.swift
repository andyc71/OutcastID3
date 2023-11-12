// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OutcastID3",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v13),
        .watchOS(.v4),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "OutcastID3",
            targets: ["OutcastID3"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.14.2"
          ),
    ],
    targets: [
        .target(
            name: "OutcastID3",
            dependencies: []
        ),
        .testTarget(
            name: "OutcastID3Tests",
            dependencies: [
                "OutcastID3",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                          ],
            resources: [
                .copy("TestData") // The test data files, copy files without modifying them
            ]
        ),
    ]
)
