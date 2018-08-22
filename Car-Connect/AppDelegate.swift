//
//  AppDelegate.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/16/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		// Use Firebase library to configure APIs
		FirebaseApp.configure()
		Fabric.with([Crashlytics.self])

		let settingsManager = SettingsManager.shared

		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
			// Enable or disable features based on authorization.
			settingsManager.notificationsEnabled = granted

			if granted {
				// set app delegate as notification center delegate to
				// receive local notifications while the app is in the foreground.
				UNUserNotificationCenter.current().delegate = self
			}
		}

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {

	}

	func applicationDidEnterBackground(_ application: UIApplication) {

	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		let settingsManager = SettingsManager.shared
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
			// Enable or disable features based on authorization.
			settingsManager.notificationsEnabled = granted
		}
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

}

extension AppDelegate: UNUserNotificationCenterDelegate {

	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		print(response.notification.request.content.userInfo)
		completionHandler()
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .badge, .sound])
	}
}
