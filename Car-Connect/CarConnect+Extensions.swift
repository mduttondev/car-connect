//
//  CarConnect+Extensions.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/16/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static let baseAppGreen = UIColor(hex: "#43A34A")
    
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var workingHex = hex
        
        if workingHex.first == "#" {
            workingHex = String(workingHex.dropFirst())
        }
        
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: alpha
        )
    }
    
}
