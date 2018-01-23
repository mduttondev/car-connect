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

	let storageHandler = StorageHandler()

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

	}

	override func viewWillAppear(_ animated: Bool) {
		if let location = locationManager.userLocation {
			centerMapOnUserLocation(location)
		}

		if let existingUserLocationCoordinate = storageHandler.getParkedLocationFromDefaults() {
			let annotation = MKPointAnnotation()
			annotation.coordinate = existingUserLocationCoordinate.coordinate
			mapView.addAnnotation(annotation)
		}

	}
    
    /*
 // TODO:
 
 1) Get All Tabs to load on start up
 
 2) Moved all the iconContainingView stuff into one class and one instance in the story board that I dont have to put all the subviews in for each.
 
 2a) I'll probably have to create a method to size the views accordingly. Might look into the work code base to do that.
 */

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
		let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
											longitude: location.coordinate.longitude)

		let region = MKCoordinateRegion(center: center,
										span: MKCoordinateSpan(latitudeDelta: Constants.span,
															   longitudeDelta: Constants.span))

		self.mapView.setRegion(region, animated: true)
	}

}
