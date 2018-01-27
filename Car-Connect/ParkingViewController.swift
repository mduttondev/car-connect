//
//  FirstViewController.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/16/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ParkingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	let locationManager = CLLocationManager()
	let storageHandler = StorageHandler()

	var userLocation: CLLocation?

	/// Current state of saved Spot
	///
	/// - spotSaved: When there is currently a saved spot
	/// - noSpotSaved: When ther is currently no saved spot
	private enum SaveStatus {
		case spotSaved
		case noSpotSaved
	}

	private var saveStatus: SaveStatus = .noSpotSaved

	// MARK: - UI Outlets -
	@IBOutlet weak var mapView: MKMapView! {
		didSet {
			mapView.showsUserLocation = true
			mapView.delegate = self
		}
	}

	@IBOutlet weak var showCurrentLocationButton: FloatingButton!
	@IBOutlet weak var parkingButton: FloatingButton!
	@IBOutlet weak var trashButton: FloatingButton!

	// MARK: - Lifecycle -
	override func viewDidLoad() {
		super.viewDidLoad()

		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

		if CLLocationManager.authorizationStatus() == .notDetermined {
			locationManager.requestWhenInUseAuthorization()
		}

		locationManager.startUpdatingLocation()

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if let existingUserLocationCoordinate = storageHandler.getParkingLocationFromDefaults() {
			let annotation = MKPointAnnotation()
			annotation.coordinate = existingUserLocationCoordinate.coordinate
			mapView.addAnnotation(annotation)
			updateUI(hasSavedLocation: true)
		} else {
			updateUI(hasSavedLocation: false)
		}
	}

	// MARK: - Button Actions -
	@IBAction func showCurrentLocationButtonPressed(_ sender: UIButton) {
		if let location = userLocation {
			centerMapOnUserLocation(location)
		}
	}

	@IBAction func saveSpotButtonPressed(_ sender: FloatingButton) {
		if saveStatus == .spotSaved {
			getDirections()
		} else {
			saveLocation()
		}

	}

	@IBAction func deletePressed(_ sender: FloatingButton) {
		storageHandler.clearSavedParkingLocation()
		mapView.annotations.forEach {
			if $0 is MKPointAnnotation {
				mapView.removeAnnotation($0)
			}
		}
		mapView.removeOverlays(mapView.overlays)
		updateUI(hasSavedLocation: false)
	}

	// MARK: -
	func updateUI(hasSavedLocation: Bool) {
		if hasSavedLocation {
			let directionsImage = #imageLiteral(resourceName: "directionsIcon")
			parkingButton.setImage(directionsImage, for: .normal)
			saveStatus = .spotSaved
			trashButton.isHidden = false
			UIView.animate(withDuration: 0.1) {
				self.trashButton.alpha = 1
			}
		} else {
			let saveIcon = #imageLiteral(resourceName: "saveIcon")
			parkingButton.setImage(saveIcon, for: .normal)
			saveStatus = .noSpotSaved
			UIView.animate(withDuration: 0.1, animations: {
				self.trashButton.alpha = 0
			}, completion: { [weak self] _ in
				self?.trashButton.isHidden = true
			})
		}
	}

	private func didUpdateUserLocation(_ location: CLLocation) {
		centerMapOnUserLocation(location)
	}

	private func centerMapOnUserLocation(_ location: CLLocation) {
		let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		let region = MKCoordinateRegion(center: center,
										span: MKCoordinateSpan(latitudeDelta: Constants.span,
															   longitudeDelta: Constants.span))

		self.mapView.setRegion(region, animated: true)
	}

	private func saveLocation() {
		guard let userLocation = userLocation else { return }
		let userLocationCoordinate = userLocation.coordinate

		let annotation = MKPointAnnotation()
		annotation.coordinate = userLocationCoordinate
		mapView.addAnnotation(annotation)
		storageHandler.writeParkedLocationToDefaults(userLocation)
		updateUI(hasSavedLocation: true)
	}

	private func getDirections() {
		print(#function)
		let savedPoint = mapView.annotations.filter { $0 is MKPointAnnotation }.first
		guard let userLocation = userLocation, let savedSpot = savedPoint else { return }
		let request = MKDirectionsRequest()
		request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate, addressDictionary: nil))
		request.destination = MKMapItem(placemark: MKPlacemark(coordinate: savedSpot.coordinate, addressDictionary: nil))
		request.requestsAlternateRoutes = false
		request.transportType = .walking

		let directions = MKDirections(request: request)
		directions.calculate { [weak self] response, error in
			guard let unwrappedResponse = response else { return }

			for route in unwrappedResponse.routes {
				self?.mapView.add(route.polyline)
				let edgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
				self?.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: edgeInsets, animated: true)
			}
		}

	}

	// MARK: MKMapView Delegate
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
		renderer.strokeColor = UIColor.blue
		return renderer
	}

	// MARK: - CLLocationManager Delegate -
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		userLocation = location
		didUpdateUserLocation(location)
	}

	private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			manager.startUpdatingLocation()
		} else {
			manager.stopUpdatingLocation()
		}
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .denied  || status == .restricted {
			locationManager.stopUpdatingLocation()
		} else {
			locationManager.startUpdatingLocation()
		}
	}

}
