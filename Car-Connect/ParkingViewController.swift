//
//  FirstViewController.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/16/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import UIKit
import MapKit

class ParkingViewController: UIViewController, CCLocationManagerDelegate, MKMapViewDelegate {

	let locationManager = CCLocationManger.sharedInstance
	let storageHandler = StorageHandler()

	@IBOutlet weak var mapView: MKMapView! {
		didSet {
			mapView.showsUserLocation = true
			mapView.delegate = self
		}
	}
	@IBOutlet weak var showCurrentLocationButton: UIButton!
	@IBOutlet weak var saveSpotButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		locationManager.delegate = self

		if let location = locationManager.userLocation {
			centerMapOnUserLocation(location)
		}
	}

	// MARK: - Button Action
	@IBAction func showCurrentLocationButtonPressed(_ sender: UIButton) {
		if let location = locationManager.userLocation {
			centerMapOnUserLocation(location)
		}
	}
	@IBAction func saveSpotButtonPressed(_ sender: UIButton) {

		guard let userLocation = locationManager.userLocation else { return }
		let userLocationCoordinate = userLocation.coordinate

		let annotation = MKPointAnnotation()
		annotation.coordinate = userLocationCoordinate
		mapView.addAnnotation(annotation)
		storageHandler.writeParkedLocationToDefaults(userLocation)
	}

	func didUpdateUserLocation(_ location: CLLocation) {
		centerMapOnUserLocation(location)
	}

	private func centerMapOnUserLocation(_ location: CLLocation) {
		let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		let region = MKCoordinateRegion(center: center,
										span: MKCoordinateSpan(latitudeDelta: Constants.span,
															   longitudeDelta: Constants.span))

		self.mapView.setRegion(region, animated: true)
	}

}
