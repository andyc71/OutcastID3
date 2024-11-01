// swift-tools-version:5.6
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
          )
        //Removing SwiftLint until it adopts swift-syntax 600.0.0 instead of pre-release
        //.package(
        //    url: "https://github.com/realm/SwiftLint", 
        //    from: "0.57.0"
        //)
    ],
    targets: [
        .target(
            name: "OutcastID3",
            dependencies: []
            //plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
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
