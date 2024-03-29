//
//  ParkingMeterViewController.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 12/3/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import UIKit
import UserNotifications

class ParkingMeterViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var meterTextField: ConfigurableActionTextField!

	@IBOutlet weak var reminderTextField: ConfigurableActionTextField!

	let pickerView = UIDatePicker()

	let storageHandler = StorageHandler()

	var activeTextField: ConfigurableActionTextField?

	var timer: Timer?

	// MARK: - LifeCycle
	override func viewDidLoad() {
		super.viewDidLoad()
		pickerView.datePickerMode = .countDownTimer

		configureTextFieldAppearance(meterTextField)
		configureTextFieldAppearance(reminderTextField)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		timer = generateTimer()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		timer?.invalidate()
	}

	// MARK: - UITextField Delegate
	func textFieldDidBeginEditing(_ textField: UITextField) {
        HapticGenerator.performImpact(ofStyle: .soft)
		activeTextField = textField as? ConfigurableActionTextField
	}

	// MARK: - Button Actions
	@objc func cancelPressed() {
		if let activeTextField = activeTextField {
			activeTextField.resignFirstResponder()
		} else {
			// Something strange happened and there isnt an active textfield but cancel was pressed anyway.
			// Just close the picker and we can start over
			view.endEditing(true)
		}

        HapticGenerator.performNotificationFeedback(ofType: .error)
	}

	@objc func doneButtonAction() {
		let date = pickerView.date
		activeTextField?.resignFirstResponder()

		let convertedDate = convertDateFromCountdown(pickerView.date)
		if activeTextField == meterTextField {
			setDate(date, inTextField: activeTextField)
			storageHandler.writeDate(convertedDate, forKey: Constants.DefaultsKey.meterExpirationKey)
		} else if activeTextField == reminderTextField {
			if SettingsManager.shared.notificationsEnabled {
				setDate(date, inTextField: activeTextField)
				setNotificationForDate(date)
				storageHandler.writeDate(convertedDate, forKey: Constants.DefaultsKey.notificationExpirationKey)
			} else {
				let alert = UIAlertController(type: .notificationsDisabled, style: .alert, positiveAction: { _ in
					if let appSettings = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(appSettings, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
					}
				})
				present(alert, animated: true, completion: nil)
			}
		}

        HapticGenerator.performNotificationFeedback(ofType: .success)
	}

	// MARK: - UI Configuration
	func configureTextFieldAppearance(_ textField: UITextField) {
		textField.delegate = self
		textField.tintColor = .clear
		textField.layer.borderColor = UIColor.lightGray.cgColor
		textField.layer.cornerRadius = 8
		textField.layer.borderWidth = 1
		textField.inputView = pickerView
		textField.inputAccessoryView = textFieldToolbar()
	}

	func configureTextField(_ textField: UITextField, forDateKey key: Constants.DefaultsKey) {
		let date = storageHandler.readDateForKey(key)

		if let savedDate = date {

			if savedDate < Date() {
				// It the date is in the past, show the expired text, remove the date for that key
				setExpiredText(textField: textField)
				pickerView.setDate(getOneMinuteDate(), animated: false)
				storageHandler.clearDefaultsKey(key)
				return

			} else if let countdownDate = convertDateToCountdown(savedDate) {
				// if the date is in the future, and can get a date from the convert methdod set it
				setDate(countdownDate, inTextField: textField)
				pickerView.setDate(countdownDate, animated: false)
				return
			}
		}

		// If there were no saved dates then show the place holder
		textField.text = ""
		pickerView.setDate(getOneMinuteDate(), animated: false)

	}

	private func setDate(_ date: Date, inTextField textField: UITextField?) {
		guard let textField = textField else { return }
		let calendar = Calendar.current

		let hours = calendar.component(.hour, from: date)
		let minutes = calendar.component(.minute, from: date)

		if hours > 0 {
			textField.text = "\(hours) Hours    \(minutes) Minutes"

		} else {
			if minutes > 1 {
				textField.text = "\(minutes) Minutes"
			} else if minutes == 1 {
				textField.text = "\(minutes) Minute"
			} else if minutes == 0 {
				textField.text = "Less than a minute"
			} else {
				setExpiredText(textField: textField)
			}
		}
	}

	private func setExpiredText(textField: UITextField) {
		textField.text = textField == meterTextField
			? "Expired"
			: "Notification Sent"
	}

	private func setNotificationForDate(_ date: Date) {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

		let content = UNMutableNotificationContent()
		content.title = "Dont forget!"
		content.subtitle = "Your parking meter is almost out of time!"
		content.sound = UNNotificationSound.default

		let calendar = Calendar.current
		let hoursInSeconds = calendar.component(.hour, from: date) * 60 * 60
		let minutesInSeconds = calendar.component(.minute, from: date) * 60

		var interval = TimeInterval(hoursInSeconds + minutesInSeconds)

        if interval < 1 {
            interval = 1
        }

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)

		let request = UNNotificationRequest(identifier: "Meter Notification",
											content: content,
											trigger: trigger)

		UNUserNotificationCenter.current().add(request) {(error) in
			if (error != nil) {
				print(error?.localizedDescription ?? "")
			}
		}
	}

	// MARK: - Convenience Methods and Date Conversion
	private func convertDateFromCountdown(_ date: Date) -> Date {
		let calendar = Calendar.current
		let hoursInSeconds = calendar.component(.hour, from: date) * 60 * 60
		let minutesInSeconds = calendar.component(.minute, from: date) * 60

		let interval = TimeInterval(hoursInSeconds + minutesInSeconds)

		let convertedDate = Date().addingTimeInterval(interval)

		return convertedDate
	}

	private func convertDateToCountdown(_ date: Date) -> Date? {
		let timeNow = Date()
		guard date > timeNow else { return nil }

		let calendar = Calendar.current

		let calendarUnits: Set<Calendar.Component> = [.hour, .minute]
		let dateComponents = calendar.dateComponents(calendarUnits, from: timeNow, to: date)

		guard let hours = dateComponents.hour, let minutes = dateComponents.minute else { return nil }
		let components = (hours: hours, minutes:  minutes)
		return getCountdownDate(from: components)

	}

	private func getCountdownDate(from time:(hours: Int, minutes: Int)) -> Date {
		let calendar = Calendar.current
		var components = DateComponents()
		components.setValue(time.hours, for: .hour)
		components.setValue(time.minutes, for: .minute)
		return calendar.date(from: components) ?? Date()
	}

	private func getOneMinuteDate() -> Date {
		let calendar = Calendar.current
		var components = DateComponents()
		components.setValue(0, for: .hour)
		components.setValue(1, for: .minute)
		return calendar.date(from: components) ?? Date()
	}

	// MARK: - Toolbar Creeation
	private func textFieldToolbar() -> UIToolbar {
		let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0,
														 y: 0,
														 width: view.frame.width,
														 height: 50))

		toolbar.barStyle = .default

		let cancel: UIBarButtonItem = UIBarButtonItem(title: "  Cancel ",
													  style: .plain,
													  target: self,
													  action: #selector(cancelPressed))

        cancel.tintColor = UIColor(named: "color_tabBarTint")

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
										target: nil,
										action: nil)

		let done: UIBarButtonItem = UIBarButtonItem(title: " Set  ",
													style: .done,
													target: self,
													action: #selector(doneButtonAction))

        done.tintColor = UIColor(named: NSLocalizedString("color_tabBarTint", comment: ""))

		var items = [UIBarButtonItem]()
		items.append(cancel)
		items.append(flexSpace)
		items.append(done)

		toolbar.items = items
		toolbar.sizeToFit()

		return toolbar
	}

	// Generate the timer object
	func generateTimer() -> Timer {
		return Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { [weak self] timer in
			guard let strongSelf = self else { return }

			guard !(strongSelf.meterTextField.isEditing || strongSelf.reminderTextField.isEditing) else { return }

			strongSelf.configureTextField(strongSelf.meterTextField, forDateKey: Constants.DefaultsKey.meterExpirationKey)
			strongSelf.configureTextField(strongSelf.reminderTextField, forDateKey: Constants.DefaultsKey.notificationExpirationKey)
		})
	}
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
