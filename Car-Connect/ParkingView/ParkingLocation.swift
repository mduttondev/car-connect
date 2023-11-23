//
//  ParkingLocation.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import CoreLocation
import Foundation

struct ParkingLocation: Identifiable, Codable, Equatable {
    let id: UUID
    let latitude: Double
    let lonitude: Double

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: lonitude)
    }

    init(id: UUID = UUID(), latitude: Double, lonitude: Double) {
        self.id = id
        self.latitude = latitude
        self.lonitude = lonitude
    }
}
