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
			url: "https://cdn.attractions.io/frameworks/maplayr-ios/v0.13/MapLayrInternal.xcframework.zip",
			checksum: "f30bff1bc7e2542f2e18eb4e56fcd1e2fd869fc832c05a404ddd0236ae2956c0"
		),
		.binaryTarget(
			name: "MapGeometry",
			url: "https://cdn.attractions.io/frameworks/map-geometry-swift/v1.3.0/MapGeometry.xcframework.zip",
			checksum: "b0bd518ca4f89e6fd08ed186f8a2cebd2c039f544bcf753222aa1ad39626022a"
		),
	]
)
