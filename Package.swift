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
        ),
        .library(
            name: "SwiftUIExTesting",
            targets: ["SwiftUIExTesting"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ilyathewhite/CombineEx.git", .upToNextMajor(from: "1.0.5")),
        .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
        .package(url: "https://github.com/ilyathewhite/FoundationEx.git", .upToNextMajor(from: "1.0.12")),
        .package(url: "https://github.com/lyft/Hammer.git", .upToNextMajor(from: "0.18.0"))
    ],
    targets: [
        .target(
            name: "SwiftUIEx",
            dependencies: ["CombineEx", "FoundationEx", .product(name: "Tagged", package: "swift-tagged")],
            swiftSettings: [
//                .unsafeFlags([
//                    "-Xfrontend",
//                    "-warn-long-function-bodies=100",
//                    "-Xfrontend",
//                    "-warn-long-expression-type-checking=100"
//                ])
            ]
        ),
        .target(
            name: "SwiftUIExTesting",
            dependencies: [
                .product(name: "Hammer", package: "Hammer", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "SwiftUIExTestingContractTests",
            dependencies: [
                "SwiftUIEx",
                "SwiftUIExTesting"
            ],
            path: "Tests/SwiftUIExTesting"
        )
    ]
)
