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
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let sendButtonSize: CGFloat = CGFloat(50.0)
        self.sendButton = IconRoundButton(frame: CGRect(
            x: self.frame.width - sendButtonSize * 1.5,
            y: self.frame.height - sendButtonSize * 1.5,
            width: sendButtonSize,
            height: sendButtonSize), iconName: "send")
//        self.sendButton.addTarget(self, action:#selector(se), for: .touchUpInside)
        self.addSubview(self.sendButton)
    }
    
    func addImage(image: UIImage) {
        self.takenImage =  UIImageView(image: image)
        self.addSubview(self.takenImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
