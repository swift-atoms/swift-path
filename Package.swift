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
            name: "Path Standard Library Integration",
            targets: ["Path Standard Library Integration"]
        ),
        .library(
            name: "Path Apple Foundation Integration",
            targets: ["Path Apple Foundation Integration"]
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
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Path",
            dependencies: [
                .product(name: "String", package: "swift-string"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Cardinal", package: "swift-cardinal"),
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
            name: "Path Standard Library Integration",
            dependencies: ["Path"]
        ),
        .target(
            name: "Path Apple Foundation Integration",
            dependencies: [
                "Path",
                "Path Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Path Tests",
            dependencies: ["Path"]
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
