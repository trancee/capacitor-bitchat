// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorTranceeBluetoothMesh",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorTranceeBluetoothMesh",
            targets: ["BluetoothMeshPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "BluetoothMeshPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/BluetoothMeshPlugin"),
        .testTarget(
            name: "BluetoothMeshPluginTests",
            dependencies: ["BluetoothMeshPlugin"],
            path: "ios/Tests/BluetoothMeshPluginTests")
    ]
)