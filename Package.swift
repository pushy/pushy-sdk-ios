// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Pushy",
  platforms: [
    .iOS(.v8), .tvOS(.v13), .watchOS(.v6)
  ],
  products: [
    .library(
      name: "Pushy",
      targets: ["Pushy"]
    ),
  ],
  targets: [
    .target(
      name: "Pushy"
    )
  ]
)
