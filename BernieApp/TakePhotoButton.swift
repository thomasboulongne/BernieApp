//
//  takePhotoButton.swift
//  BernieApp
//
//  Created by Eleve on 13/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import UIKit

class TakePhotoButton: UIButton {
    
    let padding: CGFloat
    var size: CGSize = CGSize()

    override init(frame: CGRect) {
        self.padding = 10.0
        super.init(frame: frame)
        
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor.white.cgColor
        
        self.clipsToBounds = true
        
        self.isUserInteractionEnabled = true
        
        
        self.layer.cornerRadius = self.frame.width / 2
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
