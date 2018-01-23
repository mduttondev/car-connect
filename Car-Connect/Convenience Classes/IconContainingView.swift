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

	// MARK: - Inspectables
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

	@IBInspectable var image: UIImage? {
		didSet {
			layer.borderColor = borderColor?.cgColor
		}
	}

	// MARK: - Outlets
	@IBOutlet weak var imageView: UIImageView! {
		didSet {
			imageView.image = image
		}
	}

	@IBOutlet weak var actionButton: UIButton!

	@IBOutlet weak var disablingView: UIView!

	// MARK - Properties
	var enabled: Bool {
		get {
			return disablingView.isHidden
		}
		set {
			disablingView.isHidden = newValue
		}
	}

}
