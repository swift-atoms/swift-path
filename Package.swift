// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-path",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Path",
            targets: ["Path"]
        ),
        .library(
            name: "Path Test Support",
            targets: ["Path Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-string.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ownership.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-error.git",
            branch: "main"
        ),
    ],
    targets: [
        .testTarget(
            name: "Absorbed swift-path-tagged Tests",
            dependencies: [
                .target(name: "Path"),
                .product(name: "String", package: "swift-string"),
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            path: "Tests/Absorbed swift-path-tagged"
        ),
        .testTarget(
            name: "Absorbed swift-path-error Tests",
            dependencies: [
                .target(name: "Path"),
                .product(name: "Error", package: "swift-error"),
            ],
            path: "Tests/Absorbed swift-path-error"
        ),
        .target(
            name: "Path",
            dependencies: [
                .product(name: "String", package: "swift-string"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Ownership", package: "swift-ownership"),
                .product(name: "Error", package: "swift-error"),
            ],
            swiftSettings: [
                .define(
                    "PATH_AVAILABLE",
                    .when(platforms: [
                        .macOS, .iOS, .tvOS, .watchOS, .visionOS,
                        .linux, .windows, .android, .openbsd,
                    ])
                )
            ]
        ),
        .target(
            name: "Path Test Support",
            dependencies: [
                "Path",
                .product(
                    name: "Tagged Test Support",
                    package: "swift-tagged"
                ),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Path Tests",
            dependencies: [
                .product(name: "Ownership", package: "swift-ownership"),
                "Path",
                "Path Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
