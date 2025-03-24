// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "ChatGPTReplica",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "ChatGPTReplica",
            targets: ["ChatGPTReplica"])
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
    ],
    targets: [
        .target(
            name: "ChatGPTReplica",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
            ]),
        .testTarget(
            name: "ChatGPTReplicaTests",
            dependencies: ["ChatGPTReplica"]),
        .executableTarget(name: "NewTarget"),
    ]
)
