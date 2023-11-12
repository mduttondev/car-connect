//
//  LocationManager.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import CoreLocation
import Foundation
import MapKit
import SwiftUI

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let defaultRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334606, longitude: -122.009102),
                                                  span: .init(latitudeDelta: Constants.span, longitudeDelta: Constants.span))

    private var manager = CLLocationManager()

    @Published var region = LocationManager.defaultRegion

    @Published var userCoordinate: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        setup()
    }

    func setup() {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error)")
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            locations.last.map {
                self.userCoordinate = $0
                self.region.center = $0.coordinate
            }
        }
    }
}
