//
//  HapticGenerator.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/30/19.
//  Copyright © 2019 Matthew Dutton. All rights reserved.
//

import Foundation
import UIKit

struct HapticGenerator {

    static func performImpact(ofStyle style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }

    static func performNotificationFeedback(ofType type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(type)
    }
}
