//
//  shortcutButton.swift
//  BernieApp
//
//  Created by Eleve on 12/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class IconRoundButton: UIButton {
    
    let padding: CGFloat
    var size: CGSize = CGSize()
    
    init(frame: CGRect, iconName: String) {
        self.padding = 10
        super.init(frame: frame)
        self.contentMode = .center
        let image = UIImage(named: iconName) as UIImage?
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        
        self.clipsToBounds = true
        
        self.isUserInteractionEnabled = true
        
        let maxSize = CGSize(width: UIScreen.main.bounds.width / 2.5, height: 45)
        
        self.size = self.sizeThatFits(maxSize)
        
//        self.size.width += self.padding * 2
//        self.size.height += self.padding * 2
        
        self.layer.cornerRadius = self.frame.width / 2
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
