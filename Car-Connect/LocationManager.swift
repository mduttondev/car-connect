//
//  LocationManager.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import Foundation
import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var manager: CLLocationManager?

    private let defaultRegionCoordinate: CLLocationCoordinate2D
    private let defaultCoordinateSpan: MKCoordinateSpan

    @Published var region: MKCoordinateRegion

    override init() {
        defaultRegionCoordinate = CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
        defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: Constants.span, longitudeDelta: Constants.span)

        region = MKCoordinateRegion(center: defaultRegionCoordinate,
                                    span: defaultCoordinateSpan)
    }

    func checkIfLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            manager = CLLocationManager()
            manager?.delegate = self
            manager?.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization()
        } else {
            // Go turn on LocationServices
        }
    }

    private func checkLocationAuthorization() {
        guard let manager = manager else { return }

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted")
        case .denied:
            print("You have denied, you need to go to settings to turn it on")
        case .authorizedAlways, .authorizedWhenInUse:
            print(manager.location?.coordinate)
            region = MKCoordinateRegion(center: manager.location?.coordinate ?? defaultRegionCoordinate , span: defaultCoordinateSpan)
        @unknown default:
            break;
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        region = MKCoordinateRegion(center: manager.location?.coordinate ?? defaultRegionCoordinate , span: defaultCoordinateSpan)
    }
}
