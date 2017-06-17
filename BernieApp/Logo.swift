//
//  Logo.swift
//  BernieApp
//
//  Created by Thomas BOULONGNE on 17/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class Logo: UIView {
    let animationFiles = [
        "Typing-TransIn-white",
        "Typing-TransOut-white",
        "Typing1-white",
        "Typing2-white",
        "Humeur1-Smile-white",
        "Humeur2-Search-white",
        "Humeur3-Dunno-white",
        "Humeur4-Chill-white",
        "Humeur5-Loading-white",
        "Typing-TransIn-black",
        "Typing-TransOut-black",
        "Typing1-black",
        "Typing2-black",
        "Humeur1-Smile-black",
        "Humeur2-Search-black",
        "Humeur3-Dunno-black",
        "Humeur4-Chill-black",
        "Humeur5-Loading-black"
    ]
    
    var animationViews: Dictionary<String, LOTAnimationView> = [:]
    
    var currentLogoView: String
    
    let typingTransition: Bool = false
    
    override init(frame: CGRect) {
        
        self.currentLogoView = "Humeur2-Search-" + GeneralSettings.shared.theme
        
        super.init(frame: frame)
        
        for file in animationFiles {
            let anim = LOTAnimationView(name: file)
            anim.contentMode = .scaleAspectFit
            anim.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            self.animationViews[file] = anim
            self.addSubview(self.animationViews[file]!)
            self.animationViews[file]?.isHidden = true
        }
        self.animationViews[self.currentLogoView]!.isHidden = false
    }
    
    func startTyping() {
        self.animationViews[self.currentLogoView]?.isHidden = true
        
        if self.typingTransition {
            self.currentLogoView = "Typing-TransIn-" + GeneralSettings.shared.theme
            self.animationViews[self.currentLogoView]!.isHidden = false
            self.animationViews[currentLogoView]?.animationSpeed = 1
            
            self.animationViews[self.currentLogoView]!.animationProgress = 0
            self.animationViews[self.currentLogoView]?.play(completion: { (completed) in
                
                self.animationViews[self.currentLogoView]?.isHidden = true
                self.currentLogoView = "Typing2-" + GeneralSettings.shared.theme
                self.animationViews[self.currentLogoView]!.isHidden = false
                self.animationViews[self.currentLogoView]!.loopAnimation = true
                self.animationViews[self.currentLogoView]!.play()
            })
        }
        else {
            self.currentLogoView = "Typing2-" + GeneralSettings.shared.theme
            self.animationViews[self.currentLogoView]!.isHidden = false
            self.animationViews[currentLogoView]?.animationSpeed = 1
            
            self.animationViews[self.currentLogoView]!.animationProgress = 0
            self.animationViews[self.currentLogoView]!.loopAnimation = true
            self.animationViews[self.currentLogoView]!.play()
        }
    }
    
    func stopTyping() {
        self.animationViews[self.currentLogoView]!.loopAnimation = false
        
        if self.typingTransition {
            self.animationViews[self.currentLogoView]!.pause()
            self.animationViews[self.currentLogoView]!.play(completion: { (completed) in
                self.animationViews[self.currentLogoView]!.isHidden = true
                self.currentLogoView = "Typing-TransIn-" + GeneralSettings.shared.theme
                self.animationViews[self.currentLogoView]!.isHidden = false
                self.animationViews[self.currentLogoView]!.animationSpeed = -1
                self.animationViews[self.currentLogoView]!.animationProgress = 0
                self.animationViews[self.currentLogoView]!.play()
            })
        }
        else {
            self.animationViews[self.currentLogoView]!.isHidden = true
            self.currentLogoView = "Humeur2-Search-" + GeneralSettings.shared.theme
            self.animationViews[self.currentLogoView]!.isHidden = false
            self.animationViews[self.currentLogoView]!.animationProgress = 0
        }
    }
    
    func play(file: String) {
        self.animationViews[self.currentLogoView]?.isHidden = true
        self.currentLogoView = file + "-" + GeneralSettings.shared.theme
        self.animationViews[self.currentLogoView]!.isHidden = false
        self.animationViews[self.currentLogoView]?.animationProgress = 0
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
