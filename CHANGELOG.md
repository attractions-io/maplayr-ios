# Changelog

Notable changes to MapLayr for iOS will be kept in this file. MapLayr uses semantic versioning: expect breaking changes before 1.0.

## 0.15

### Breaking Changes

- `UserLocationMarker` no longer conforms to `CameraPositionProvider` or `CameraOrientationProvider`: instead, it exposes two new properties, `cameraPositionProvider` and `cameraOrientationProvider`, which can be used as the camera providers on the map view.
- `UserLocationMarker` now uses the `Position` type instead of `CLLocation`.
- `UserLocationMarker` now uses a `Heading` type rather than a tuple containing the orientation and accuracy.
- `CameraPositionProvider` and `CameraOrientationProvider` now both extend the new `Provider` protocol with just an extra `isAnimating` property. `cameraPosition` and `cameraOrientation` become `current` and `cameraPositionPublisher` and `cameraOrientationPublisher` becomes `updates` (and the publishers no longer include the new value).
- `PathNetwork` no longer has `calculateDirections`-variants which contained an explicit layer ID. Use the new `MultilevelCoordinate`-based methods instead which use level IDs.
- `CoordinateAnnotationLayer`'s initialisers have renamed the `coordinate` parameter to `coordinates`.
- `CoordinateAnnotationLayer`'s initialisers no longer contain an optional `level` parameter which accepted a tuple of a building and level ID. Use the new variants which accept a `MultilevelCoordinate` instead.
- `MapView` no longer has `convert`-variants which accept a `level` parameter. Use the new variants which accept a `MultilevelCoordinate` instead.
- `MapView`'s `showLevel` function now just accepts a single level ID rather than a `Building` and `Level` structure.

### Added

- Building level IDs are now considered globally unique across all buildings.
- `Provider` generic protocol added for types which have a current value and can update with new values.
- `MultilevelCoordinates` is a new structure which wraps a `Coordinates` and a level ID (`String?`). `MultilevelMapPoint` does the same for `MapPoint`.
- `Position` is a new structure which wraps a `MultilevelCoordinates`, and also includes other sensor-derived data such as `horizontalAccuracy`.
- `ReactiveRoute` is a `Provider<Route?>` which can have `Provider`s for its origin and destination locations and path network. It can be created from a `Map`.
- `Shape` is now a class and it can accept a `Provider<Path?>` (which a `ReactiveRoute` can provide) which will automatically update its appearance on the map.
- A new `ManagementDelegate` can be added to a static property of `Map`, which can be used to customise some map download behaviour.
