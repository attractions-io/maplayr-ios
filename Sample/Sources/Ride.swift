//
//  Ride.swift
//  MapLayr Sample
//
//  Created by Robert Pugh on 2023-09-28.
//

import Foundation
import MapLayr

struct Ride: Equatable, Hashable {
	var name: String
	var coordinates: Coordinates
}

let rides = [
	Ride(name: "Daeva",               coordinates: .init(latitude: 52.8952, longitude: -1.8431)),
	Ride(name: "Eagle’s Nest",        coordinates: .init(latitude: 52.8982, longitude: -1.8463)),
	Ride(name: "Tarragon",            coordinates: .init(latitude: 52.8983, longitude: -1.8494)),
	Ride(name: "The Flying Dutchman", coordinates: .init(latitude: 52.8971, longitude: -1.8443)),
	Ride(name: "Wooden Warrior",      coordinates: .init(latitude: 52.8949, longitude: -1.8445)),
]
