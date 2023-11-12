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

public enum Constants {

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
