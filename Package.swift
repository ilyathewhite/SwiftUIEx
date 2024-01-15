// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIEx",
    platforms: [
        .macOS("13.0"), .iOS("16.0"), .tvOS(.v14)
    ],
    products: [
        .library(
            name: "SwiftUIEx",
            targets: ["SwiftUIEx"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ilyathewhite/CombineEx.git", .branch("main")),
        .package(url: "https://github.com/ilyathewhite/FoundationEx.git", .branch("main")),
        .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.5.0")
    ],
    targets: [
        .target(
            name: "SwiftUIEx",
            dependencies: ["CombineEx", "FoundationEx", .product(name: "Tagged", package: "swift-tagged")],
            swiftSettings: [.unsafeFlags([
                "-Xfrontend",
                "-warn-long-function-bodies=100",
                "-Xfrontend",
                "-warn-long-expression-type-checking=100"
            ])]
        )
    ]
)
