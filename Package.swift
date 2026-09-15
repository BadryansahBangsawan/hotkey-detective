// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HotkeyDetective",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "HotkeyDetective", targets: ["HotkeyDetective"])
    ],
    targets: [
        .executableTarget(name: "HotkeyDetective", path: "Sources")
    ]
)
