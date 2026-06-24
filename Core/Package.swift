// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MandarinCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MandarinCore",
            targets: ["MandarinCore"]
        )
    ],
    targets: [
        .target(
            name: "MandarinCore",
            path: ".",
            exclude: [
                "Package.swift"
            ],
            sources: [
                "Models",
                "Services",
                "Persistence",
                "Content",
                "DesignSystem"
            ]
        )
    ]
)
