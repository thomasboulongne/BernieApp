//
//  BackgroundImageView.swift
//  BernieApp
//
//  Created by Eleve on 15/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class BackgroundImageView: UIView {
    
    let backgroundImage: UIImageView!
    
    init(frame: CGRect, image: UIImage) {
        let frame = CGRect(x: frame.width / 2 - frame.height / 2, y: 0, width: frame.height, height: frame.height)
        self.backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        self.backgroundImage.image = image
        self.backgroundImage.contentMode = .scaleAspectFill
        
        
        super.init(frame: frame)
 
        self.clipsToBounds = true
        self.addSubview(self.backgroundImage)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
