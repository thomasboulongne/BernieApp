//
//  Header.swift
//  BernieApp
//
//  Created by Thomas on 6/6/17.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class Header: UIView {
    
    let gradient: CAGradientLayer
    
    var currentLogoView: String = ""
    
    let logo: Logo
    
    override init(frame: CGRect) {
        self.gradient = CAGradientLayer()
        
        self.logo = Logo(frame: CGRect(x: (frame.width / 2) - (logoSize + logoPadding * 2) / 2, y: UIApplication.shared.statusBarFrame.height + vMargin * 1.5 - logoPadding, width: logoSize + logoPadding * 2, height: logoSize + logoPadding * 2))
        
        super.init(frame: frame)
                
        self.addSubview(self.logo)
    }
    
    func startTyping() {
        self.logo.startTyping()
    }
    
    func stopTyping() {
        self.logo.stopTyping()
    }
    
    func setupGradient() {
        
        var topColor: UIColor = .white
        var bottomColor: UIColor = .white
        
        topColor = themes(theme: GeneralSettings.shared.theme)["whiteBg"]!
        bottomColor = themes(theme: GeneralSettings.shared.theme)["whiteBg"]!.withAlphaComponent(0.0)
        
        self.gradient.frame = self.frame
        
        self.gradient.startPoint = CGPoint(x: 0.0, y: 0.65)
        self.gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        self.gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        
        self.layer.insertSublayer(self.gradient, at: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
