//
//  LocationManager.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject {

    private let manager: CLLocationManager?

    @Published private(set) var userLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        let manager = CLLocationManager()
        self.manager = manager
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        handleAuthorization(authorizationStatus)
    }

    /// Test-only initializer that feeds a fixed sequence of locations, bypassing
    /// CoreLocation entirely. No system permission prompt is ever shown.
    init(simulatedLocations: [CLLocation], interval: TimeInterval = 0.25) {
        self.manager = nil
        super.init()
        self.authorizationStatus = .authorizedWhenInUse
        if let first = simulatedLocations.first {
            self.userLocation = first
        }
        let rest = Array(simulatedLocations.dropFirst())
        guard !rest.isEmpty else { return }
        Task { @MainActor [weak self] in
            for location in rest {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                guard let self else { return }
                self.userLocation = location
            }
        }
    }

    func requestAuthorization() {
        guard let manager else { return }
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    /// Returns the freshest known location: the most recent delegate update if
    /// available, otherwise CoreLocation's cached value. The cached value is
    /// often populated immediately on app launch (especially in the simulator)
    /// before our delegate's didUpdateLocations has fired.
    func bestAvailableLocation() -> CLLocation? {
        if let userLocation { return userLocation }
        return manager?.location
    }

    private func handleAuthorization(_ status: CLAuthorizationStatus) {
        guard let manager else { return }
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        @unknown default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            self.handleAuthorization(status)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error)")
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            if let existing = self.userLocation?.coordinate,
               existing.latitude == latest.coordinate.latitude,
               existing.longitude == latest.coordinate.longitude {
                return
            }
            self.userLocation = latest
        }
    }
}

// MARK: - GPX loading (used by UI tests via LocationManager(simulatedLocations:))

enum GPXLoader {
    /// Loads a GPX file from the main bundle (with or without the `.gpx` extension)
    /// and returns its waypoints / trackpoints as CLLocations.
    static func loadLocations(named name: String) -> [CLLocation] {
        let resource = (name as NSString).deletingPathExtension
        guard let url = Bundle.main.url(forResource: resource, withExtension: "gpx"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        let parser = XMLParser(data: data)
        let delegate = GPXParserDelegate()
        parser.delegate = delegate
        guard parser.parse() else { return [] }
        return delegate.locations
    }
}

private final class GPXParserDelegate: NSObject, XMLParserDelegate {
    var locations: [CLLocation] = []

    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes: [String: String] = [:]) {
        guard elementName == "wpt" || elementName == "trkpt" else { return }
        guard let latString = attributes["lat"], let lat = Double(latString),
              let lonString = attributes["lon"], let lon = Double(lonString) else {
            return
        }
        locations.append(CLLocation(latitude: lat, longitude: lon))
    }
}
