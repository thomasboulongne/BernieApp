//
//  takenPhotoView.swift
//  BernieApp
//
//  Created by Eleve on 13/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import UIKit

class TakenPhotoView: UIView {

    var takenImage: UIImageView!
    
    var sendButton: IconRoundButton!
    var backButton: IconRoundButton!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.isHidden = true
        let sendButtonSize: CGFloat = CGFloat(50.0)
        self.sendButton = IconRoundButton(frame: CGRect(
            x: self.frame.width - sendButtonSize * 1.5,
            y: self.frame.height - sendButtonSize * 1.5,
            width: sendButtonSize,
            height: sendButtonSize), iconName: "send", notTemplate: true)
        self.addSubview(self.sendButton)
        
        let backButtonSize: CGFloat = CGFloat(closeButtonHeight)
        
        self.backButton = IconRoundButton(frame: CGRect(
            x: backButtonSize,
            y: backButtonSize,
            width: backButtonSize,
            height: backButtonSize), iconName: "back")
        self.backButton.addTarget(self, action:#selector(self.back), for: .touchUpInside)
        self.addSubview(self.backButton)
        
        self.takenImage =  UIImageView()
        self.takenImage.frame = self.frame
        self.addSubview(self.takenImage)
    }
    
    func addImage(image: UIImage) {
        self.isHidden = false
        self.takenImage.image = image
        self.bringSubview(toFront: self.sendButton)
        self.bringSubview(toFront: self.backButton)
    }
    
    func back() {
        self.isHidden = true
        
        let controller = self.parentViewController as! CameraViewController
        controller.disclaimer.animate(newText: "Pas de chaton mignon, sinon je fond...", characterDelay: 0.03)
        controller.logo.play(file: "Humeur4-Chill")
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
