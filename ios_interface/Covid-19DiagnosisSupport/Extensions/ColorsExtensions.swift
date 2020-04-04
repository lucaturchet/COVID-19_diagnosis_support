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
    
    struct FlatColors {
        static let borderGray = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        static let totalsGray = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        static let containerGray = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        static let yellow = UIColor(red: 242/255, green: 226/255, blue: 59/255, alpha: 1)
        static let brown = UIColor(red: 182/255, green: 103/255, blue: 38/255, alpha: 1)
        static let red = UIColor(red: 186/255, green: 23/255, blue: 13/255, alpha: 1)
        static let darkGray = UIColor(red: 125/255, green: 124/255, blue: 124/255, alpha: 1)
    }
}
