//
//  ColorsExtensions.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 22/03/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit

extension UIColor {
    struct DynamicColors {
        static let whiteBlack = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case
              .unspecified,
              .light: return .white
            case .dark: return .black
            @unknown default:
                return .white
            }
        }
        static let blackWhite = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case
              .unspecified,
              .light: return .black
            case .dark: return .white
            @unknown default:
                return .black
            }
        }
    }
    
}
