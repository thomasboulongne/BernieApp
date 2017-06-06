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
    let logo: LOTAnimationView
    
    override init(frame: CGRect) {
        self.gradient = CAGradientLayer()
        
        self.logo = LOTAnimationView(name: "loading_rainbow")
        
        self.logo.contentMode = .scaleAspectFit
        
        super.init(frame: frame)
        
        self.logo.frame = CGRect(x: (self.bounds.width / 2) - logoSize.width / 2, y: UIApplication.shared.statusBarFrame.height + vMargin, width: logoSize.width, height: logoSize.height)
        
        self.addSubview(self.logo)
    }
    
    func setupGradient() {
        
        let topColor: UIColor = .white
        let bottomColor: UIColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        
        self.gradient.frame = self.frame
        
        //self.gradient.locations = self.setGradientLocations()
        
        self.gradient.startPoint = CGPoint(x: 0.0, y: 0.7)
        self.gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        self.gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        
        self.layer.insertSublayer(self.gradient, at: 0)
        
    }
    
    func play() {
        self.logo.animationProgress = 0
        self.logo.play(completion: { finished in
            print("adele replay dat shit pls")
            self.play()
        })
        
    }
    
    func setGradientLocations() -> [NSNumber]
    {
        return [0.70, 1.0]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
