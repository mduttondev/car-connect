//
//  Car_ConnectApp.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct Car_ConnectApp: App {

    init() {
        FirebaseApp.configure()

        if ProcessInfo.processInfo.arguments.contains("-UITEST_RESET") {
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: Constants.DefaultsKey.locationKey.rawValue)
            defaults.removeObject(forKey: Constants.DefaultsKey.meterExpirationKey.rawValue)
            defaults.removeObject(forKey: Constants.DefaultsKey.reminderFireDateKey.rawValue)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
