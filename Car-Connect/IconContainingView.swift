//
//  IconContainingView.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 12/3/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import UIKit

@IBDesignable
class IconContainingView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
