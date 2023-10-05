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
			url: "https://cdn.attractions.io/frameworks/maplayr-ios/v0.7/MapLayrInternal.xcframework.zip",
			checksum: "7b558e95a929358a52b5a6e052de4c31f302a69d8a65fa1fc69de687d27f9e60"),
		.binaryTarget(
			name: "MapGeometry",
			url: "https://cdn.attractions.io/frameworks/map-geometry-swift/v1.3.0/MapGeometry.xcframework.zip",
			checksum: "b0bd518ca4f89e6fd08ed186f8a2cebd2c039f544bcf753222aa1ad39626022a"
		),
	]
)
