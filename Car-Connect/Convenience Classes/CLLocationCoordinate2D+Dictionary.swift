//
//  CLLocationCoordinate2D+Dictionary.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 1/22/18.
//  Copyright © 2018 Matthew Dutton. All rights reserved.
//

import Foundation
import CoreLocation

typealias CLLocationDictionary = [String: CLLocationDegrees]
extension CLLocationCoordinate2D {

	private static let Lat = "lat"
	private static let Lon = "lon"

	var asDictionary: CLLocationDictionary {
		return [CLLocationCoordinate2D.Lat: self.latitude,
				CLLocationCoordinate2D.Lon: self.longitude]
	}

	init(dict: CLLocationDictionary) {
		self.init(latitude: dict[CLLocationCoordinate2D.Lat]!,
				  longitude: dict[CLLocationCoordinate2D.Lon]!)
	}

}
