//
//  SettingsManager.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 3/11/18.
//  Copyright © 2018 Matthew Dutton. All rights reserved.
//

import Foundation

class SettingsManager {

	static let shared = SettingsManager()

	var notificationsEnabled: Bool = false

	private init() { }

	// TODO: Expand this to include theme (light, dark)

}
