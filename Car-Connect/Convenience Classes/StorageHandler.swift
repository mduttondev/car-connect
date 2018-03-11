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

	private let locationKey = Constants.DefaultsKey.locationKey.rawValue

	// MARK: - Parking Location Defaults
	func readParkingLocationFromDefaults() -> CLLocation? {
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
		guard let _ = defaults.object(forKey: locationKey) else { return }
		defaults.removeObject(forKey: locationKey)
	}

	// MARK: - Meter Expiration Defaults
	func readDateForKey(_ key: Constants.DefaultsKey) -> Date? {
		guard let date = UserDefaults.standard.object(forKey: key.rawValue) as? Date else { return nil }
		return date
	}

	func writeDate(_ date: Date, forKey key: Constants.DefaultsKey) {
		UserDefaults.standard.set(date, forKey: key.rawValue)
	}

	func clearDefaultsKey(_ key: Constants.DefaultsKey) {
		guard let _ = UserDefaults.standard.object(forKey: key.rawValue) else { return }
		UserDefaults.standard.removeObject(forKey: key.rawValue)
	}
}
