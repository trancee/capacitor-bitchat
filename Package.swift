// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorTranceeBitchat",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorTranceeBitchat",
            targets: ["BitchatPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "BitchatPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/BitchatPlugin"),
        .testTarget(
            name: "BitchatPluginTests",
            dependencies: ["BitchatPlugin"],
            path: "ios/Tests/BitchatPluginTests")
    ]
)