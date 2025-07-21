//
//  ViewController.swift
//  MapLayr Sample
//
//  Created by Robert Pugh on 2023-09-28.
//

import UIKit
import MapLayr
import CoreLocation
import Combine

class ViewController: UIViewController {
	/// The ID of the demo map.
	let mapID = "5a1400cf-db2b-4dec-90f2-8f603cab4e72"
	
	var map: Map!
	@IBOutlet var mapView: MapView!
	
	// A user location marker without any parameters automatically tracks the device location and heading.
	let userLocationMarker = UserLocationMarker()
	
	let locationManager = CLLocationManager()
	
	@IBOutlet var mapDownloadIndicator: UIActivityIndicatorView!
	@IBOutlet var mapDownloadButton: UIButton!
	@IBOutlet var statusBarProtection: UIView!
	@IBOutlet var mapControls: UIView!
	@IBOutlet var zoomToUserLocationButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Request permission to use location services.
		locationManager.requestWhenInUseAuthorization()
		
		// Get location updates to update the route.
		locationManager.delegate = self
		locationManager.startUpdatingLocation()
		
		// Loads the map into the map view.
		loadMap()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Checks if the API key is correctly installed
		verifyApiKey()
	}
	
	private func verifyApiKey() {
		let key = (Bundle.main.infoDictionary?["Attractions.io"] as? [String:Any?])?["APIKey"] as? String
		
		if key == nil {
			let alert = UIAlertController(title: "No API Key", message: "You haven’t configured an API key for this project. Add a key called 'APIKey' inside the 'Attractions.io' key in Info.plist.", preferredStyle: .alert)
			
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			
			present(alert, animated: true)
		}
	}
	
	/// Holds reference for receiving update to the map's current version.
	private var mapVersionUpdater: AnyCancellable?
	
	/// Loads the map object and assigns it to the map view.
	@IBAction private func loadMap() {
		mapDownloadButton.isHidden = true
		
		Task {
			do {
				// Fetches the map object. There is a synchronous version available, but this will only succeed if the map is bundled with the application, or the map has already been downloaded.
				// Even with the asynchronous version, this function will return immediately if the map doesn't need to be downloaded.
				map = try await Map.managed(id: mapID)
				
				/// Receives updates to the map's version, so that the zoom to user location button can be updated if the bounds changes.
				mapVersionUpdater = map.$currentVersion.receive(on: RunLoop.main).sink(receiveValue: { [weak self] _ in self?.updateLocationButtonAvailability() })
				
				// Assign the map to the map view.
				mapView.map = map
				
				// Assign this view controller to be a delegate of the map view.
				// This is used to be notified if the user unlocks the camera by dragging away.
				mapView.delegate = self
				
				// Add the user location marker.
				mapView.addUserLocationMarker(userLocationMarker)
				
				// Add the annotations.
				addAnnotations()
				
				// Reveal the map view.
				mapView.isHidden = false
				statusBarProtection.isHidden = false
				mapControls.isHidden = false
				
				mapDownloadIndicator.stopAnimating()
			} catch {
				showMapDownloadError()
			}
		}
		
		if map == nil {
			mapDownloadIndicator.startAnimating()
		}
	}
	
	/// Displays an error message to the user informing them that the map cannot be downloaded, and prepares the UI for retrying the map download in the future.
	private func showMapDownloadError() {
		let alert = UIAlertController(
			title: "Cannot Show Map",
			message: "The map cannot be displayed at this time, please check your internet connection and try again.",
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		
		present(alert, animated: true)
		
		mapDownloadIndicator.stopAnimating()
		mapDownloadButton.isHidden = false
	}
	
	/// Adds the ride annotations to the map view.
	private func addAnnotations() {
		// Create the annotation layer.
		let layer = CoordinateAnnotationLayer<Ride>(
			coordinates: \.coordinates,
			view: {
				let view = LabeledAnnotationIcon(icon: #imageLiteral(resourceName: "Annotation"), text: $0.name)
				
				view.imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 30 / 34)
				view.spacing = -14
				
				view.label.highlightedTextColor = .red
				
				view.label.textStrokeWidth = 3
				
				view.label.layer.shadowOpacity = 0.5
				view.label.layer.shadowOffset = .zero
				view.label.layer.shadowRadius = 1.5
				view.label.layer.shouldRasterize = true
				
				return view
			}
		)
		
		// Set the view controller as the map layer's delegate.
		layer.delegate = self
		
		// Add the annotations to the annotation layer.
		layer.insert(rides)
		
		// Add the annotation layer to the map view.
		mapView.addMapLayer(layer)
	}
	
	/// The current route's destination, if a route is currently active.
	private var routeDestination: Coordinates? = nil {
		didSet {
			updateRoute()
		}
	}
	
	/// Updates the route.
	///
	/// This method should be called whenever the origin or destination of the route changes.
	private func updateRoute() {
		guard let mapView else {
			return
		}
		
		let path: Path?
		
		setPath: do {
			guard let originLocation = locationManager.location?.coordinate else {
				path = nil
				break setPath
			}
			
			guard let destinationLocation = routeDestination else {
				path = nil
				break setPath
			}
			
			let route = map.currentVersion.pathNetwork!.calculateDirections(from: Coordinates(originLocation), to: [ destinationLocation ])
			
			guard let route else {
				print("A route to the destination was not found.")
				path = nil
				break setPath
			}
			
			path = route.path
		}
		
		if let path {
			let innerShape = Shape(path: path, strokeColor: #colorLiteral(red: 0.9096202274, green: 0.9848581969, blue: 1, alpha: 1).cgColor, strokeWidth: 10)
			let outerShape = Shape(path: path, strokeColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor, strokeWidth: 5)
			
			mapView.shapes = [ innerShape, outerShape ]
		} else {
			mapView.shapes = []
		}
	}
	
	/// Enables or disables the "zoom to user location" button depending on whether the user is within the map bounds.
	///
	/// This method should be called if either the user's location updates or the map bounds updates, as either event may cause the user location button's availability to change.
	func updateLocationButtonAvailability() {
		let shouldEnable: Bool
		
		checkAvailability: do {
			guard let location = locationManager.location?.coordinate else {
				shouldEnable = false
				break checkAvailability
			}
			
			guard let map, map.currentVersion.bounds.contains(Coordinates(location).mapPoint(using: .webMercator)) else {
				shouldEnable = false
				break checkAvailability
			}
			
			shouldEnable = true
		}
		
		zoomToUserLocationButton.isEnabled = shouldEnable
	}
	
	/// Toggle between locking the user location marker to the position, the position and orientation, or unlock the camera, depending on the current state.
	@IBAction func zoomToUserLocation() {
		if mapView.positionProvider == nil {
			lockCameraPosition()
		} else if mapView.orientationProvider == nil {
			lockCameraOrientation()
		} else {
			unlockCamera()
		}
	}
	
	/// Zooms the camera to the user's location, pointing towards the route destination, if both locations are available.
	///
	/// The camera is positioned so that at least 50 metres is visible around the user in all directions. The heading of the camera is adjusted to point at the route's destination, and the camera is tilted 45°.
	@IBAction func zoomToRouteFocusedLocation() {
		guard let location = locationManager.location?.coordinate else {
			return
		}
		
		guard let destination = routeDestination else {
			return
		}
		
		mapView.moveCamera(
			coordinates: location,
			heading: Coordinates(location).bearing(to: destination),
			span: 50,
			tilt: .pi / 4,
			animated: true
		)
	}
	
	/// Zooms the camera so that all the annotations are visible.
	///
	/// The camera is positioned so that all the annotations are just visible, with an extra 50 points of margin to account for the sizes of the annotations themselves. The camera's heading is left at its previous value.
	@IBAction func zoomToAnnotations() {
		let annotationCoordinates = rides.map(\.coordinates)
		
		guard let (center, span) = computeSmallestCircle(coordinates: annotationCoordinates) else {
			return
		}
		
		mapView.moveCamera(
			coordinates: center,
			span: span,
			insets: 50,
			tilt: 0,
			animated: true
		)
	}
	
	/// Locks the camera (and zooms in) so that its position tracks the user location marker.
	private func lockCameraPosition() {
		mapView.setProvider(position: userLocationMarker.cameraPositionProvider, animated: true)
		mapView.moveCamera(span: 50, animated: true)
		
		zoomToUserLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
	}
	
	/// Locks the camera so that its orientation tracks the user location marker.
	///
	/// Additionally tilt the camera to 45°.
	private func lockCameraOrientation() {
		mapView.setProvider(orientation: userLocationMarker.cameraOrientationProvider, animated: true)
		mapView.moveCamera(tilt: .pi / 4, animated: true)
		
		zoomToUserLocationButton.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
	}
	
	/// Unlocks the camera so that it doesn't move with the user location marker.
	private func unlockCamera() {
		if mapView.positionProvider != nil {
			mapView.positionProvider = nil
		}
		
		if mapView.orientationProvider != nil {
			mapView.orientationProvider = nil
		}
		
		zoomToUserLocationButton.setImage(UIImage(systemName: "location"), for: .normal)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		switch traitCollection.userInterfaceStyle {
		case .dark:
			return .lightContent
		default:
			return .darkContent
		}
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		.allButUpsideDown
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		setNeedsStatusBarAppearanceUpdate()
	}
}

extension ViewController: MapViewDelegate {
	func mapViewDidChangeCameraPositionProvider(_ mapView: MapView, positionProvider: (any CameraPositionProvider)?, oldProvider: (any CameraPositionProvider)?) {
		if positionProvider == nil {
			unlockCamera()
		}
	}
	
	func mapViewDidChangeCameraOrientationProvider(_ mapView: MapView, orientationProvider: (any CameraOrientationProvider)?, oldProvider: (any CameraOrientationProvider)?) {
		if orientationProvider == nil {
			unlockCamera()
		}
	}
}

extension ViewController: CoordinateAnnotationLayerDelegate {
	typealias Element = Ride
	
	func didDeselectAnnotation(_ element: Ride, in annotationLayer: CoordinateAnnotationLayer<Ride>) {
		routeDestination = nil
	}
	
	func didSelectAnnotation(_ element: Ride, in annotationLayer: CoordinateAnnotationLayer<Ride>) {
		routeDestination = element.coordinates
	}
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		updateRoute()
		updateLocationButtonAvailability()
	}
}
