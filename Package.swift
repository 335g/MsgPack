// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var isSwiftPackagerManagerTest: Bool {
    return ProcessInfo.processInfo.environment["SWIFTPM_TEST_MsgPack"] == "YES"
}

let package = Package(
    name: "MsgPack",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MsgPack",
            targets: ["MsgPack"]),
    ],
    dependencies: {
        var deps: [Package.Dependency] = []
        
        if isSwiftPackagerManagerTest {
            deps += [
                .package(url: "https://github.com/typelift/SwiftCheck", .branchItem("master"))
            ]
        }
        return deps
    }(),
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MsgPack",
            dependencies: []),
        .testTarget(
            name: "MsgPackTests",
            dependencies: ["MsgPack"]),
    ],
    swiftLanguageVersions: [4]
)
