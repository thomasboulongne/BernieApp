//
//  Header.swift
//  BernieApp
//
//  Created by Thomas on 6/6/17.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class Header: UIView {
    
    let gradient: CAGradientLayer
    
    override init(frame: CGRect) {
        self.gradient = CAGradientLayer()
        super.init(frame: frame)
    }
    
    func setupGradient() {
        
        let topColor: UIColor = .white
        let bottomColor: UIColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        
        print(self.frame)
        
        self.gradient.frame = self.frame
        
        //self.gradient.locations = self.setGradientLocations()
        
        self.gradient.startPoint = CGPoint(x: 0.0, y: 0.7)
        self.gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        self.gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        
        self.layer.insertSublayer(self.gradient, at: 0)
        
        print(self.layer.sublayers)
        
        
        
    }
    
    func setGradientLocations() -> [NSNumber]
    {
        return [0.70, 1.0]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
