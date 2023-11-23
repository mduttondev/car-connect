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

    static let locationKey = Constants.DefaultsKey.locationKey.rawValue

    static func getParkingLocation() -> ParkingLocation? {
        guard let data = UserDefaults.standard.object(forKey: locationKey) as? Data else { return nil }

        let decoder = JSONDecoder()
        if let savedData = try? decoder.decode(ParkingLocation.self, from: data) {
            return savedData
        }

        return nil
    }

    static func setParkingLocation(location: ParkingLocation) {
        guard let encodedData = try? JSONEncoder().encode(location) else { return }
        UserDefaults.standard.setValue(encodedData,
                                       forKey: locationKey)
    }

	/// Removes saved parking location if one exists
    static func clearSavedParkingLocation() {
        UserDefaults.standard.removeObject(forKey: locationKey)
	}

	// MARK: - Meter Expiration Defaults
    static func readDateForKey(_ key: Constants.DefaultsKey) -> Date? {
		guard let date = UserDefaults.standard.object(forKey: key.rawValue) as? Date else { return nil }
		return date
	}

    static func writeDate(_ date: Date, forKey key: Constants.DefaultsKey) {
		UserDefaults.standard.set(date, forKey: key.rawValue)
	}

    static func clearDefaultsKey(_ key: Constants.DefaultsKey) {
		guard let _ = UserDefaults.standard.object(forKey: key.rawValue) else { return }
		UserDefaults.standard.removeObject(forKey: key.rawValue)
	}
}
