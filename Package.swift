// swift-tools-version: 5.7

import PackageDescription

let package = Package(
	name: "MapLayr",
	platforms: [
		.iOS(.v13)
	],
	products: [
		.library(
			name: "MapLayr",
			targets: [
				"MapLayr",
			]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/weichsel/ZIPFoundation.git",
			from: "0.9.16"
		),
	],
	targets: [
		.target(
			name: "MapLayr",
			dependencies: [
				"MapLayrInternal",
				"MapGeometry",
				.product(name: "ZIPFoundation", package: "ZIPFoundation"),
			]
		),
		.binaryTarget(
			name: "MapLayrInternal",
			url: "https://cdn.attractions.io/frameworks/maplayr-ios/v0.6/MapLayrInternal.xcframework.zip",
			checksum: "d67b33ecb1054f4418581d42ac3a2ad92ff8a28cbb3d06d11a26bb1d04d634df"),
		.binaryTarget(
			name: "MapGeometry",
			url: "https://cdn.attractions.io/frameworks/map-geometry-swift/v1.1.0/MapGeometry.xcframework.zip",
			checksum: "507b0cc1bc90edb2c75f27ac8c38c2e91ccc4dc1b923328d00d9aba4ceeeb2e2"
		),
	]
)
