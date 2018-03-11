//
//  ParkingViewController.swift
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
	var callDirectionCount: Int = 0

	private var directionsBeingDisplayed = false

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

		if let existingUserLocationCoordinate = storageHandler.readParkingLocationFromDefaults() {
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
		let deleteConfirmed: ((UIAlertAction) -> Void) = { [weak self] _ in
			self?.clearSavedSpotAndDirections()
		}

		let alert = UIAlertController(type: .confirmSpotDelete, positiveAction: deleteConfirmed)
		present(alert, animated: true, completion: nil)
	}

	private func clearSavedSpotAndDirections() {
		storageHandler.clearSavedParkingLocation()
		mapView.annotations.forEach {
			if $0 is MKPointAnnotation {
				mapView.removeAnnotation($0)
			}
		}
		mapView.removeOverlays(mapView.overlays)
		updateUI(hasSavedLocation: false)

		directionsBeingDisplayed = false
		callDirectionCount = 3

		if let userLocation = userLocation {
			centerMapOnUserLocation(userLocation)
		}
	}

	// MARK: - Configuration
	func updateUI(hasSavedLocation: Bool) {
		let animationDuration = Constants.defaultAnimationDuration
		if hasSavedLocation {
			let directionsImage = #imageLiteral(resourceName: "directionsIcon")
			parkingButton.setImage(directionsImage, for: .normal)
			saveStatus = .spotSaved
			trashButton.isHidden = false
			UIView.animate(withDuration: animationDuration) {
				self.trashButton.alpha = 1
			}
		} else {
			let saveIcon = #imageLiteral(resourceName: "saveIcon")
			parkingButton.setImage(saveIcon, for: .normal)
			saveStatus = .noSpotSaved
			UIView.animate(withDuration: animationDuration, animations: {
				self.trashButton.alpha = 0
			}, completion: { [weak self] _ in
				self?.trashButton.isHidden = true
			})
		}
	}

	private func didUpdateUserLocation(_ location: CLLocation) {
		centerMapOnUserLocation(location)

		callDirectionCount += 1

		if directionsBeingDisplayed && callDirectionCount % Constants.overlayUpdateRate == 0 {
			getDirections()
		}
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

		let savedPoint = mapView.annotations.filter { $0 is MKPointAnnotation }.first
		let userLocation = mapView.annotations.filter { $0 is MKUserLocation }.first

		guard let user = userLocation, let marker = savedPoint else { return }

		let request = MKDirectionsRequest()
		request.source = MKMapItem(placemark: MKPlacemark(coordinate: user.coordinate, addressDictionary: nil))
		request.destination = MKMapItem(placemark: MKPlacemark(coordinate: marker.coordinate, addressDictionary: nil))
		request.requestsAlternateRoutes = false
		request.transportType = .walking

		let existingOverlay = mapView.overlays.first

		let directions = MKDirections(request: request)
		directions.calculate { [weak self] response, error in
			guard let strongSelf = self,
				let unwrappedResponse = response else { return }

			for route in unwrappedResponse.routes {
				strongSelf.mapView.add(route.polyline)
				let inset = Constants.mapEdgeInsetsForOverylay
				let edgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)

				if !strongSelf.directionsBeingDisplayed {
					strongSelf.directionsBeingDisplayed = true
					strongSelf.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: edgeInsets, animated: true)
				}
			}

			if let oldOverlay = existingOverlay {
				strongSelf.mapView.remove(oldOverlay)
			}
		}

	}

	// MARK: - MKMapView Delegate -
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
		renderer.strokeColor = UIColor.blue
		renderer.lineWidth = Constants.lineWidth
		return renderer
	}

	// MARK: - CLLocationManager Delegate -
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		userLocation = location
		didUpdateUserLocation(location)
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .denied  || status == .restricted {
			locationManager.stopUpdatingLocation()
		} else {
			locationManager.startUpdatingLocation()
		}
	}

}
