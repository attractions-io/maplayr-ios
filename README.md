# MapLayr

*MapLayr* for iOS is an SDK for displaying interactive maps. It is written in Swift and uses Metal for rendering.

# Installation

## Swift Package Manager

MapLayr can be added to your Xcode project using Swift Package Manager.

1. Select your project file in Xcode.
2. Select the project in the column containing the projects and targets, and then select *Package Dependencies*.
3. Click the *+* button and paste the repository URL into the *Search or Enter Package URL* field.
4. The single repository should appear. While this project is still in development, you can keep the dependency rule's default value (master branch).
5. Press *Add Package*, and then *Add Package* again.

### Private Repository Note

This project is not yet available in a public GitHub repository. Therefore, you may additionally need to:

- Use the SSH-based URL when adding the Swift package.
- Add your GitHub account, with access to the repository, to Xcode, and link your private key.

# Usage

*Note that in this preview release the API is subject to change.*

MapLayr provides the class `MapView`, a subclass of `UIView`. It can be configured with a `Map` instance, which itself is configured from the map bundled in your app.

## Adding the Map Bundle

To have maps available when the app first launches, they must be available at a known location inside your app bundle.

1. In Xcode, create a folder reference named "AppLayr" in the top-level directory of your application.
2. Inside that folder, create another folder named "Maps".

To add a maps bundle to your Maps folder, you can use the `download-map` script included with this repository. It takes the following parameters:

- `-m` or `--map`: The ID of the map.
- `-d` or `--dir`: The directory to download the map bundle into. In most projects this will be your Maps folder.
- `-n` or `--name`: Save the map bundle using a custom name. If you are using managed maps, you should leave this parameter out, in which case the map will be named using the map ID.
- `--skip-if-exists`: If this option is supplied, the map will not be downloaded if a map already exists in the destination.
- `--skip-if-debug`: If this option is supplied, the map will not be downloaded if the environment variable `CONFIGURATION` is set to `Debug`, which is useful when executing the script from Xcode.

To keep the map up-to-date, we recommend adding a build phase in Xcode which runs the script when you build your app:

1. In Xcode, in your target's *Build Phases*, add a new *Run Script* phase, and drag it so that it appears before your existing *Copy Bundle Resources* phase.
2. Call your new phase something like "Update Map", and uncheck "based on dependency analysis".
3. Add the following code to execute, updating the supplied map ID and target directory accordingly:

```shell
"${BUILD_DIR%Build/*}SourcePackages/checkouts/maps-ios/download-map" -m "5a1400cf-db2b-4dec-90f2-8f603cab4e72" -d "$PROJECT_DIR/My App/AppLayr/Maps" --skip-if-debug
```

(Note that this way of locating the `download-map` script is potentially unreliable, so you might want to copy it into your project and call it from there instead.)

When your app is built, and the map doesn't already exist or it is not a debug build, the script will download the latest copy of your map and install it into the location specified, ready to be loaded from the app.

We recommend adding the Maps folder to your .gitignore file.

## Displaying a Map

To display an interactive map on the screen, you must first get a managed `Map` instance by specifying your map ID. The map must be located in the correct place in your application bundle (see above). Getting a "managed" map instance, rather than instantiating a `Map` yourself, allows the map to be updated automatically:

```swift
let map = try! Map.managed(id: "5a1400cf-db2b-4dec-90f2-8f603cab4e72")
```

Next, create a `MapView` instance and add it to the screen, and assign it the `Map` you created:

```swift
let mapView = MapView()
mapView.map = map

view.addSubview(mapView)
mapView.frame = view.bounds
```

## Showing the User's Location

The SDK includes the class `UserLocationMarker` whose instances can be added to the `MapView` to display the user's location:

```swift
let locationMarker = UserLocationMarker()
mapView.addUserLocationMarker(locationMarker)
```

By default, user location markers automatically determine the user's position and heading, though it does not request permission to use location services, you must do this yourself.

The location manager can instead be configured to show some other location and/or heading. Either or both properties can be passed into the initialiser to prevent the marker from using location services at all:

```swift
let locationMarker = UserLocationMarker(
	location: CLLocation(latitude: 52.8994, longitude: -1.857),
	heading: ( direction: 43.5, accuracy: 20 )
)
```

The location manager provides `overrideLocation` and `overrideHeading` properties which can be used to update the displayed location and heading. Either property can be set to `nil` to have the location manager determine the value instead.

## Showing Annotations

Annotations are added to a `CoordinateAnnotationLayer`, which is then added to the `MapView`. Each annotation layer is specialised with the type of annotation which is added to it, such as a "point of interest" type. Except for being `Hashable`, there are no other constraints imposed upon the type, but you must instantiate the coordinate layer with two closures which separately determine the coordinates and provide a view for instances of the given type.

For example, given the following `PointOfInterest` class:

```swift
final class PointOfInterest: Hashable {
	let name: String
	let location: CLLocationCoordinate2D
}
```

A coordinate layer can be instantiated and added to the map view:

```swift
let layer = CoordinateAnnotationLayer<PointOfInterest>(
	coordinate: \.location,
	view: { LabeledAnnotationIcon(icon: UIImage(named: "POIIcon")!, text: $0.name) }
)
```

`LabeledAnnotationIcon` is a standard view which displays an icon and a label, but custom views conforming to `CoordinateAnnotationView` can also be supplied.

To populate the layer with annotations, you can pass any sequence of your annotation type to the layer's `insert` method:

```swift
layer.insert(allPointsOfInterest)
```

Finally, you can add the layer to the map view:

```swift
mapView.addMapLayer(layer)
```

## Calculating & Showing Routes

The SDK can calculate routes between two points and display them on the map.

You can use the `PathNetwork` instance supplied by the `Map` to calculate the route from one location to another:

```swift
let userLocation = locationManager.location
let destinationLocation = CLLocationCoordinate2D(latitude: 52.8994, longitude: -1.857)

guard let route = map.pathNetwork.calculateDirections(from: userLocation, to: [ destinationLocation ]) else {
	throw Error("A route could not be calculated to the destination")
}
```

Multiple possible endpoints can be supplied, for example if a destination had multiple entrances—the resulting route will use the closest destination. Additionally, `calculateDirections` takes an optional final argument to specify route options, such as avoiding path segments flagged as unsuitable for wheelchairs & pushchairs.

The returned `Route` has properties for its total distance and a `Path` instance, which can be added to the map view as a shape:

```swift
let shape = Shape(path: route.path, strokeColor: UIColor.red.cgColor, strokeWidth: 8)
mapView.shapes = [ shape ]
```

## Setting the Camera

It is often desirable to zoom the map to a certain position, or reveal all the annotations, etc. The map view contains a method, `moveCamera`, which allows changing the projection, optionally with an animation:

```swift
mapView.moveCamera(
	coordinates: CLLocationCoordinate2D(latitude: 52.8994, longitude: -1.857),
	heading: 43.5,
	span: 50,
	insets: 0,
	tilt: .pi / 4,
	animated: true
)
```

All arguments are optional and, left out, preserve the camera's current state.

A function which calculates the smallest enclosing circle for a number of coordinates is included in the SDK to make determining the coordinates and span to provide easier:

```swift
let ( center, span ) = computeSmallestCircle(coordinates: allPointsOfInterest.map(\.coordinate))

mapView.moveCamera(
	coordinates: center,
	span: span,
	insets: 50,
	tilt: 0,
	animated: true
)
```

# Sample Code

See [the included sample application](Sample/) for an example of how to use the MapLayr SDK.

# License

[Contact us](mailto:sales@attractions.io) for a license to use MapLayr.
