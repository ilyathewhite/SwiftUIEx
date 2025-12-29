// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIEx",
    platforms: [
        .macOS("15.0"), .iOS("16.0"), .tvOS(.v14)
    ],
    products: [
        .library(
            name: "SwiftUIEx",
            targets: ["SwiftUIEx"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ilyathewhite/CombineEx.git", .upToNextMinor(from: "1.0.5"))
    ],
    targets: [
        .target(
            name: "SwiftUIEx",
            dependencies: ["CombineEx"],
            swiftSettings: [
//                .unsafeFlags([
//                    "-Xfrontend",
//                    "-warn-long-function-bodies=100",
//                    "-Xfrontend",
//                    "-warn-long-expression-type-checking=100"
//                ])
            ]
        )
    ]
)
