//
//  ParkingMarker.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/11/23.
//

import CoreLocation
import Foundation

struct ParkingMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
