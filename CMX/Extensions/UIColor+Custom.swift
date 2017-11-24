//
//  UIColor+Custom.swift
//  CMX
//
//  Created by Nikolay Derkach on 10/3/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import Foundation
import UIKit

// Usage Examples
let shadowColor = Color.shadow.value
let shadowColorWithAlpha = Color.shadow.withAlpha(0.5)
let customColorWithAlpha = Color.custom(hexString: "#123edd", alpha: 0.25).value

enum Color {

    case shadow
    case defaultGray
    case defaultGrayWithOpacity

    case custom(hexString: String, alpha: Double)

    func withAlpha(_ alpha: Double) -> UIColor {
        return value.withAlphaComponent(CGFloat(alpha))
    }
}

extension Color {

    var value: UIColor {
        var instanceColor = UIColor.clear

        switch self {
        case .shadow:
            instanceColor = UIColor.black.withAlphaComponent(0.33)
        case .defaultGray:
            instanceColor = UIColor(red: 42/255.0, green:56/255.0, blue:66/255.0, alpha:1.0)
        case .defaultGrayWithOpacity:
            instanceColor = Color.defaultGray.withAlpha(0.2315160778985507)
        case let .custom(hexValue, opacity):
            instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
        }
        return instanceColor
    }
}

extension UIColor {
    /**
     Creates an UIColor from HEX String in "#363636" format

     - parameter hexString: HEX String in "#363636" format

     - returns: UIColor from HexString
     */
    convenience init(hexString: String) {

        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString as String)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x0000_00FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
