//
//  StorageHandler.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 1/22/18.
//  Copyright © 2018 Matthew Dutton. All rights reserved.
//

import Foundation

struct StorageHandler {

    static let locationKey = Constants.DefaultsKey.locationKey.rawValue
    static let meterExpirationKey = Constants.DefaultsKey.meterExpirationKey.rawValue
    static let reminderFireDateKey = Constants.DefaultsKey.reminderFireDateKey.rawValue

    // MARK: - Parking location

    static func getParkingLocation() -> ParkingLocation? {
        guard let data = UserDefaults.standard.data(forKey: locationKey) else { return nil }
        return try? JSONDecoder().decode(ParkingLocation.self, from: data)
    }

    static func setParkingLocation(location: ParkingLocation) {
        guard let encodedData = try? JSONEncoder().encode(location) else { return }
        UserDefaults.standard.set(encodedData, forKey: locationKey)
    }

    /// Removes saved parking location if one exists.
    static func clearSavedParkingLocation() {
        UserDefaults.standard.removeObject(forKey: locationKey)
    }

    // MARK: - Meter expiration + reminder

    static func getMeterExpiration() -> Date? {
        UserDefaults.standard.object(forKey: meterExpirationKey) as? Date
    }

    static func setMeterExpiration(_ date: Date) {
        UserDefaults.standard.set(date, forKey: meterExpirationKey)
    }

    static func clearMeterExpiration() {
        UserDefaults.standard.removeObject(forKey: meterExpirationKey)
    }

    static func getReminderFireDate() -> Date? {
        UserDefaults.standard.object(forKey: reminderFireDateKey) as? Date
    }

    static func setReminderFireDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: reminderFireDateKey)
    }

    static func clearReminderFireDate() {
        UserDefaults.standard.removeObject(forKey: reminderFireDateKey)
    }
}
