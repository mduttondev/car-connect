//
//  SecondViewController.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/16/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import UIKit
import MapKit

class FindViewController: UIViewController, CCLocationManagerDelegate {

	@IBOutlet weak var mapView: MKMapView! {
		didSet {
			mapView.showsUserLocation = true
		}
	}

	@IBOutlet weak var showCurrentLocationButton: UIButton!
	@IBOutlet weak var showDirectionsButton: UIButton!

	let locationManager = CCLocationManger.sharedInstance

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	@IBAction func showCurrentLocationButtonPressed(_ sender: UIButton) {
		if let location = locationManager.userLocation {
			centerMapOnUserLocation(location)
		}
	}
	@IBAction func showDirectionsButtonPressed(_ sender: UIButton) {
	}

	func didUpdateUserLocation(_ location: CLLocation) {
		centerMapOnUserLocation(location)
	}

	private func centerMapOnUserLocation(_ location: CLLocation) {
		let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))

		self.mapView.setRegion(region, animated: true)
	}

}
