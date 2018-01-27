//
//  StorageHandler.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 1/22/18.
//  Copyright © 2018 Matthew Dutton. All rights reserved.
//

import Foundation
import CoreLocation

struct StorageHandler {

	private let locationKey = "ParkedLocation"

	func getParkingLocationFromDefaults() -> CLLocation? {
		guard let coordinateDictionary = UserDefaults.standard.object(forKey: locationKey) as? CLLocationDictionary else { return nil }
		let coordinate = CLLocationCoordinate2D(dict: coordinateDictionary)
		let location = CLLocation(latitude: coordinate.latitude,
								  longitude: coordinate.longitude)
		return location
	}

	/// Write provided CLLCLLocation to UserDefaults
	///
	/// - Parameter location: CLLocation to save
	func writeParkedLocationToDefaults(_ location: CLLocation) {
		let coordinate = location.coordinate
		let storableCoordinate = coordinate.asDictionary
		UserDefaults.standard.set(storableCoordinate, forKey: locationKey)
	}

	/// Removes saved parking location if one exists
	func clearSavedParkingLocation() {
		let defaults = UserDefaults.standard
		guard let _ = defaults.object(forKey: locationKey) as? CLLocationDictionary else { return }

		defaults.removeObject(forKey: locationKey)
	}
}
