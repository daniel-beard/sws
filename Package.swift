// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSearcher",
    products: [
        .executable(name: "sws",
            targets: ["sws"]),
        .library(name: "SwiftSearcherCore",
            targets: ["SwiftSearcherCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/davedufresne/SwiftParsec.git", exact: "4.0.1"),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50700.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", exact: "0.14.1"),
    ],
    targets: [
        // CLI app
        .executableTarget( name: "sws",
            dependencies: ["SwiftSearcherCore"]),
        // Library
        .target( name: "SwiftSearcherCore",
            dependencies: [
                "SwiftParsec",
                "lib_InternalSwiftSyntaxParser",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SQLite", package: "SQLite.swift"), 
                
                ]),
        .testTarget(
            name: "SwiftSearcherCoreTests",
            dependencies: ["SwiftSearcherCore"]),
        .binaryTarget(
            name: "lib_InternalSwiftSyntaxParser",
            url: "https://github.com/keith/StaticInternalSwiftSyntaxParser/releases/download/5.7/lib_InternalSwiftSyntaxParser.xcframework.zip",
            checksum: "99803975d10b2664fc37cc223a39b4e37fe3c79d3d6a2c44432007206d49db15"
        ),
    ]
)
