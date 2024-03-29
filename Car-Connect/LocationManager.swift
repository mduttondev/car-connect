//
//  LocationManager.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 12/17/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import Foundation
import CoreLocation

protocol CCLocationManagerDelegate: AnyObject {
	func didUpdateUserLocation(_ location: CLLocation)
}

class CCLocationManger: NSObject, CLLocationManagerDelegate {

	static let sharedInstance = CCLocationManger()

	var userLocation: CLLocation?
	private let locationManager = CLLocationManager()

	weak var delegate: CCLocationManagerDelegate?

	private override init() {
		super.init()
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		userLocation = location
		delegate?.didUpdateUserLocation(location)
	}

	private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			manager.distanceFilter = 100.0
			manager.desiredAccuracy = kCLLocationAccuracyBest
			manager.startUpdatingLocation()
		} else {
			manager.stopUpdatingLocation()
		}
	}

}
