//
//  Constants.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 1/22/18.
//  Copyright © 2018 Matthew Dutton. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

public enum Constants {

    static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334606, longitude: -122.009102),
        span: Constants.defaultSpan
    )

    static let defaultSpan = MKCoordinateSpan(latitudeDelta: Constants.span,
                                              longitudeDelta: Constants.span)

    static let narrowSpan: CLLocationDegrees = 0.002
    static let span: CLLocationDegrees = 0.01 // initial fallback only — user zoom is preserved after first camera change

    enum DefaultsKey: String {
        case locationKey = "ParkedLocation"
        case meterExpirationKey = "MeterExpiration"
        case reminderFireDateKey = "ReminderFireDate"
    }
}
