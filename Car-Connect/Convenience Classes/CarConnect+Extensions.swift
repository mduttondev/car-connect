//
//  CarConnect+Extensions.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/16/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension Color {
    static let baseAppGreen = Color("appGreen")
}

extension Optional: RawRepresentable where Wrapped: Codable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self) else {
            return "{}"
        }
        return String(decoding: data, as: UTF8.self)
    }

    public init?(rawValue: String) {
        guard let value = try? JSONDecoder().decode(Self.self, from: Data(rawValue.utf8)) else {
            return nil
        }
        self = value
    }
}
