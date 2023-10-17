// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Shield",
  platforms: [
    .iOS("10.0"),
    .macOS("10.12"),
    .watchOS("3.0"),
    .tvOS("10.0"),
  ],
  products: [
    .library(
      name: "Shield",
      targets: ["Shield", "ShieldSecurity", "ShieldCrypto", "ShieldOID", "ShieldPKCS", "ShieldX509", "ShieldX500"]),
  ],
  dependencies: [
    .package(url: "https://gitlab.e-imza.az/emilmsyv/PotentCodables.git", revision: "66e5e5cc64f6ad171e94f2d5a4399823df664b79"),
    .package(url: "https://gitlab.e-imza.az/emilmsyv/RegexKit.git", revision: "e31bd88a752478d3fb1f019e4fb53f3d6f9696ff")
  ],
  targets: [
    .target(
      name: "Shield",
      dependencies: ["ShieldSecurity", "ShieldCrypto", "ShieldOID", "ShieldPKCS", "ShieldX509", "ShieldX500"]
    ),
    .target(
      name: "ShieldOID",
      dependencies: ["PotentCodables"]
    ),
    .target(
      name: "ShieldX500",
      dependencies: ["ShieldOID", "PotentCodables"]
    ),
    .target(
      name: "ShieldPKCS",
      dependencies: ["ShieldX500", "PotentCodables"]
    ),
    .target(
      name: "ShieldX509",
      dependencies: ["ShieldCrypto", "ShieldX500", "ShieldOID", "ShieldPKCS", "PotentCodables"]
    ),
    .target(
      name: "ShieldCrypto"
    ),
    .target(
      name: "ShieldSecurity",
      dependencies: ["ShieldCrypto", "ShieldOID", "ShieldPKCS", "ShieldX500", "ShieldX509", "PotentCodables", "RegexKit"]
    ),
    .testTarget(
      name: "ShieldTests",
      dependencies: ["Shield"],
      path: "Tests"
    ),
  ]
)
