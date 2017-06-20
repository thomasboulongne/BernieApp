//
//  ctaButton.swift
//  BernieApp
//
//  Created by Thomas BOULONGNE on 16/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class CtaButton: UILabel {
    
    let padding: CGFloat
    var size: CGSize = CGSize()
    let payload: String
    
    init(frame: CGRect, text: String, padding: CGFloat, payload: String, maxSize: CGSize) {
        
        self.padding = padding
        
        self.payload = payload
        
        super.init(frame: frame)
        
        self.text = text
        self.font = UIFont(name: "Magneta-Book", size: 14)
        
        let buttonMaxSize = CGSize(width: maxSize.width - (2 * detailsPadding), height: maxSize.height)
        self.size = self.sizeThatFits(buttonMaxSize)
        
        self.clipsToBounds = true
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.brnGreyish.cgColor
        self.textColor = UIColor.brnBlack
        
        
        self.layer.cornerRadius = (self.size.height + detailsPadding * 2) / 2
        
        self.size.width += detailsPadding * 2
        self.size.height += detailsPadding * 2
        
        self.drawText(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: self.padding, left: self.padding, bottom: self.padding, right: self.padding)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
