//
//  FloatingButton.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 1/27/18.
//  Copyright © 2018 Matthew Dutton. All rights reserved.
//

import UIKit

@IBDesignable
class FloatingButton: UIButton {

	@IBInspectable var cornerRadius: CGFloat = 0.0 {
		didSet {
			layer.cornerRadius = cornerRadius
		}
	}

	@IBInspectable var imageInset: CGFloat = 0.0 {
		didSet {
			self.imageEdgeInsets = UIEdgeInsets(top: imageInset, left: imageInset, bottom: imageInset, right: imageInset)
		}
	}

	@IBInspectable var borderWidth: CGFloat = 0.0 {
		didSet {
			layer.borderWidth = borderWidth
		}
	}

	@IBInspectable var borderColor: UIColor = .darkGray {
		didSet {
			layer.borderColor = borderColor.cgColor
		}
	}

}
