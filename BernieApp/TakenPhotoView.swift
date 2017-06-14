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
    var chosenImage: UIImage!
    
    var sendButton: IconRoundButton!
    var backButton: IconRoundButton!
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let sendButtonSize: CGFloat = CGFloat(50.0)
        self.sendButton = IconRoundButton(frame: CGRect(
            x: self.frame.width - sendButtonSize * 1.5,
            y: self.frame.height - sendButtonSize * 1.5,
            width: sendButtonSize,
            height: sendButtonSize), iconName: "send")
        self.addSubview(self.sendButton)
        
        let backButtonSize: CGFloat = CGFloat(closeButtonHeight)
        
        self.backButton = IconRoundButton(frame: CGRect(
            x: backButtonSize,
            y: backButtonSize,
            width: backButtonSize,
            height: backButtonSize), iconName: "back")
        self.backButton.addTarget(self, action:#selector(self.back), for: .touchUpInside)
        self.addSubview(self.backButton)
    }
    
    func addImage(image: UIImage) {
        self.isHidden = false
        self.chosenImage = image
        self.takenImage =  UIImageView(image: self.chosenImage)
        self.addSubview(self.takenImage)
        self.bringSubview(toFront: self.sendButton)
        self.bringSubview(toFront: self.backButton)
    }
    
    
    func back() {
        self.isHidden = true
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
