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
    /// When the user saved this spot. Optional for back-compat with spots
    /// persisted by older builds that didn't record a timestamp — those decode
    /// to `nil` and simply show no parked duration.
    let parkedAt: Date?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(id: UUID = UUID(), latitude: Double, longitude: Double, parkedAt: Date? = Date()) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.parkedAt = parkedAt
    }

    // Back-compat: older builds persisted the typo'd key "lonitude".
    private enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case lonitude
        case parkedAt
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
        self.parkedAt = try container.decodeIfPresent(Date.self, forKey: .parkedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encodeIfPresent(parkedAt, forKey: .parkedAt)
    }
}
