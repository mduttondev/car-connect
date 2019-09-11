//
//  UIAlertController+StandardAlerts.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 1/28/18.
//  Copyright © 2018 Matthew Dutton. All rights reserved.
//

import UIKit

extension UIAlertController {

	typealias ButtonHandler = ((UIAlertAction) -> Void)?

	struct AlertContent {
		let title: String?
		let message: String?
		let style: UIAlertController.Style
		let actions: [UIAlertAction]?
	}

	enum AlertType {
		case confirmSpotDelete
		case notificationsDisabled
	}

	/// Creates a UIAlertController based on a given type.
	/// This type is used to populate the content title, message, and buttons
	/// It is assumed there will be a 2 button maximum
	///
	/// - Parameters:
	///   - type: AlertType used to get the content for the alert shown
	///   - style: UIAlertControllerStyle to be used with this alert, defaults to `.alert`
	///   - positiveAction: ButtonHandler to be used with the (positive/proceed) response from the user
	///   - negativeAction: ButtonHandler to be used with the (negative/cancel) response from the user
	convenience init(type: AlertType, style: UIAlertController.Style = .alert, positiveAction: ButtonHandler = nil, negativeAction: ButtonHandler = nil) {
		self.init(title: nil, message: nil, preferredStyle: style)

		let alertContent = getContent(forType: type, positiveAction: positiveAction, negativeAction: negativeAction)

		title = alertContent.title
		message = alertContent.message

		alertContent.actions?.forEach {
			addAction($0)
		}

	}

	private func getContent(forType type: AlertType, positiveAction: ButtonHandler = nil, negativeAction: ButtonHandler = nil) -> AlertContent {
		switch type {
		case .confirmSpotDelete:
			let title = "Are you sure?"
			let message = "This will remove your saved parking space and any directions currently displayed"
			let proceedAction = UIAlertAction(title: "Delete", style: .destructive, handler: positiveAction)
			let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: negativeAction)
			return AlertContent(title: title, message: message, style: .alert, actions: [proceedAction, cancelAction])
		case .notificationsDisabled:
			let title = "Notifications Disabled"
			let message = "Notifications are currently disabled for this application. Please turn on notifications in settings and try that again"
			let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: positiveAction)
			let cancelAction = UIAlertAction(title: "Never mind", style: .default, handler: negativeAction)
			return AlertContent(title: title, message: message, style: .alert, actions: [settingsAction, cancelAction])
		}
	}

}
