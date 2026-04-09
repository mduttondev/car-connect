//
//  ParkingLocation.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import CoreLocation
import Foundation

struct ParkingLocation: Identifiable, Codable, Equatable {
    let id: UUID
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(id: UUID = UUID(), latitude: Double, longitude: Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }

    // Back-compat: older builds persisted the typo'd key "lonitude".
    private enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case lonitude
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        if let lon = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            self.longitude = lon
        } else {
            self.longitude = try container.decode(Double.self, forKey: .lonitude)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
