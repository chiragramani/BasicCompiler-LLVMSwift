// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodeGen-LLVMSwift",
    platforms: [.macOS(.v10_14)],
    dependencies: [
        .package(name: "LLVM",
            url: "https://github.com/llvm-swift/LLVMSwift.git",
            from: "0.8.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CodeGen-LLVMSwift",
            dependencies: ["LLVM"]),
        .testTarget(
            name: "CodeGen-LLVMSwiftTests",
            dependencies: ["CodeGen-LLVMSwift"]),
    ]
)
