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
			url: "https://cdn.attractions.io/frameworks/maplayr-ios/v0.8/MapLayrInternal.xcframework.zip",
			checksum: "82740eabcceeba1691736b3107c5e24bd377584b90ee9dc1f7e8a8de5436c68c"),
		.binaryTarget(
			name: "MapGeometry",
			url: "https://cdn.attractions.io/frameworks/map-geometry-swift/v1.3.0/MapGeometry.xcframework.zip",
			checksum: "b0bd518ca4f89e6fd08ed186f8a2cebd2c039f544bcf753222aa1ad39626022a"
		),
	]
)
