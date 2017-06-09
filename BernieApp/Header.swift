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
    var animationViews: Dictionary<String, LOTAnimationView> = [:]
    
    var currentLogoView: String = ""
    
    override init(frame: CGRect) {
        self.gradient = CAGradientLayer()
        
        let animationFiles = [
//            "1-white",
//            "2-white",
//            "3-white",
//            "4-white",
//            "5-white",
            "Typing-TransIn-white",
            "Typing-TransIn2-white",
            "Typing1-white",
            "Typing2-white"
        ]
        
        super.init(frame: frame)
        
        for file in animationFiles {
            let anim = LOTAnimationView(name: file)!
            anim.contentMode = .scaleAspectFit
            anim.frame = CGRect(x: (self.bounds.width / 2) - (logoSize + logoPadding * 2) / 2, y: UIApplication.shared.statusBarFrame.height + vMargin - logoPadding, width: logoSize + logoPadding * 2, height: logoSize + logoPadding * 2)
            self.animationViews[file] = anim
        }
        
        self.currentLogoView = "Typing-TransIn-white"
        self.addSubview(self.animationViews[self.currentLogoView]!)
    }
    
    func startTyping() {
        self.animationViews[self.currentLogoView]?.removeFromSuperview()
        
        self.currentLogoView = "Typing-TransIn-white"
        self.addSubview(self.animationViews[self.currentLogoView]!)
        self.animationViews[currentLogoView]?.animationSpeed = 3
        
        self.animationViews[self.currentLogoView]!.animationProgress = 0
        self.animationViews[self.currentLogoView]?.play(completion: { (completed) in
            
            print(self.animationViews[self.currentLogoView]!.animationProgress)
            self.animationViews[self.currentLogoView]?.removeFromSuperview()
            self.currentLogoView = "Typing2-white"
            self.addSubview(self.animationViews[self.currentLogoView]!)
            self.animationViews[self.currentLogoView]!.loopAnimation = true
            self.animationViews[self.currentLogoView]!.play()
        })
    }
    
    func stopTyping() {
        
        self.animationViews[self.currentLogoView]!.pause()
        self.animationViews[self.currentLogoView]!.loopAnimation = false
        self.animationViews[self.currentLogoView]!.play(completion: { (completed) in
            self.animationViews[self.currentLogoView]!.removeFromSuperview()
            self.currentLogoView = "Typing-TransIn-white"
            self.addSubview(self.animationViews[self.currentLogoView]!)
            self.animationViews[self.currentLogoView]!.animationSpeed = -3
            self.animationViews[self.currentLogoView]!.animationProgress = 1
            self.animationViews[self.currentLogoView]!.play()
        })
    }
    
    func setupGradient() {
        
        let topColor: UIColor = .white
        let bottomColor: UIColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        
        self.gradient.frame = self.frame
        
        self.gradient.startPoint = CGPoint(x: 0.0, y: 0.75)
        self.gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        self.gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        
        self.layer.insertSublayer(self.gradient, at: 0)
        
    }
    
    func play(file: String) {
        self.animationViews[self.currentLogoView]?.removeFromSuperview()
        self.addSubview(self.animationViews[file]!)
        self.currentLogoView = file
        self.animationViews[self.currentLogoView]?.play()
    }
    
    func stop() {
        self.animationViews[self.currentLogoView]?.pause()
        self.animationViews[self.currentLogoView]?.play(completion: { (completed) in
            self.animationViews[self.currentLogoView]?.pause()
            self.animationViews[self.currentLogoView]?.loopAnimation = false
            self.animationViews[self.currentLogoView]?.animationProgress = 0
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
