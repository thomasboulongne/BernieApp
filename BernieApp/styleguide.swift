//
//  styleguide.swift
//  BernieApp
//
//  Created by Thomas BOULONGNE on 16/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class var brnGreyish: UIColor {
        return UIColor(white: 180.0 / 255.0, alpha: 1.0)
    }
    
    class var brnBrownishGrey: UIColor {
        return UIColor(white: 94.0 / 255.0, alpha: 1.0)
    }
    
    class var brnWarmGrey: UIColor {
        return UIColor(white: 144.0 / 255.0, alpha: 1.0)
    }
    
    class var brnBlack: UIColor {
        return UIColor(white: 45.0 / 255.0, alpha: 1.0)
    }
    
    class var brnWhite: UIColor {
        return UIColor(white: 214.0 / 255.0, alpha: 1.0)
    }
    
    class var brnBlackTwo: UIColor {
        return UIColor(white: 34.0 / 255.0, alpha: 1.0)
    }
    
    class var brnClearBlue: UIColor {
        return UIColor(red: 34.0 / 255.0, green: 108.0 / 255.0, blue: 1.0, alpha: 1.0)
    }
    
    class var brnPaleGold: UIColor {
        return UIColor(red: 1.0, green: 215.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0)
    }
    
    class var brnTomato: UIColor {
        return UIColor(red: 237.0 / 255.0, green: 46.0 / 255.0, blue: 46.0 / 255.0, alpha: 1.0)
    }
    
    class var brnLightishBlue: UIColor {
        return UIColor(red: 66.0 / 255.0, green: 128.0 / 255.0, blue: 1.0, alpha: 1.0)
    }
}

// Text styles

extension UIFont {
    class func brnH1Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-75Bd", size: 28.0)
    }
    
    class func brnH2Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-65Md", size: 26.0)
    }
    
    class func brnH3Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-65Md", size: 20.0)
    }
    
    class func brnH4Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-65Md", size: 18.0)
    }
    
    class func brnUserTextSentFont() -> UIFont? {
        return UIFont(name: "Magneta-Book", size: 16.0)
    }
    
    class func brnSubhead1Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-55Rg", size: 16.0)
    }
    
    class func brnH5Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-65Md", size: 16.0)
    }
    
    class func brnUserTextingFont() -> UIFont? {
        return UIFont(name: "Magneta-Book", size: 14.0)
    }
    
    class func brnUserButtonFont() -> UIFont? {
        return UIFont(name: "Magneta-Book", size: 14.0)
    }
    
    class func brnUserPlaceholderFont() -> UIFont? {
        return UIFont(name: "Magneta-Book", size: 14.0)
    }
    
    class func brnBodyFont() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-55Rg", size: 14.0)
    }
    
    class func brnSubhead2Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-55Rg", size: 14.0)
    }
    
    class func brnH6Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-65Md", size: 14.0)
    }
    
    class func brnSYRendreStyleFont() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-65Md", size: 14.0)
    }
    
    class func brnLabelsFont() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-65Md", size: 14.0)
    }
    
    class func brnSubhead3Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-55Rg", size: 12.0)
    }
    
    class func brnH7Font() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-65Md", size: 12.0)
    }
    
    class func brnSmallFont() -> UIFont? {
        return UIFont(name: "NHaasGroteskDSPro-55Rg", size: 11.0)
    }
};

func themes(theme: String) -> Dictionary<String, UIColor> {
    var themes = Dictionary<String, Dictionary<String,UIColor>>()
    themes["white"] = Dictionary<String, UIColor>()
    themes["white"]?["white"] = .white
    themes["white"]?["whiteBg"] = .white
    themes["white"]?["whitish"] = .brnWhite
    themes["white"]?["black"] = .brnBlack
    
    themes["black"] = Dictionary<String, UIColor>()
    themes["black"]?["white"] = .brnBlack
    themes["black"]?["whiteBg"] = .brnBlackTwo
    themes["black"]?["whitish"] = .brnWhite
    themes["black"]?["black"] = .brnWhite
    
    return themes[theme]!
    
}
