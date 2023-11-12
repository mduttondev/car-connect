//
//  Constants.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 1/22/18.
//  Copyright © 2018 Matthew Dutton. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation
import MapKit

public enum Constants {

    static let defaultRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334606, longitude: -122.009102),
                                                  span: Constants.defaultSpan)

    static let defaultSpan = MKCoordinateSpan(latitudeDelta: Constants.span, longitudeDelta: Constants.span)

    static let narrowSpan: CLLocationDegrees = 0.002
    static let span: CLLocationDegrees = 0.0025

	static let defaultAnimationDuration: TimeInterval = 0.1

	static let lineWidth: CGFloat = 6.0
	static let mapEdgeInsetsForOverylay: CGFloat = 20.0

	static let overlayUpdateRate: Int = 5

	enum DefaultsKey: String {
		case locationKey = "ParkedLocation"
		case meterExpirationKey = "MeterExpiration"
		case notificationExpirationKey = "NotificationExpiration"
	}
}
