// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ValidatorKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "ValidatorKit", targets: ["ValidatorKit"]),
    ],
    targets: [
        .target(
            name: "ValidatorKit",
            path: "Sources/ValidatorKit"
        ),
        .testTarget(
            name: "ValidatorKitTests",
            dependencies: ["ValidatorKit"],
            path: "Tests/ValidatorKitTests"
        ),
    ]
)
