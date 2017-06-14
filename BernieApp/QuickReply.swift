//
//  QuickReply.swift
//  BernieApp
//
//  Created by Thomas on 6/8/17.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class QuickReply: UILabel {
    
    let padding: CGFloat
    var size: CGSize = CGSize()
    let id: Int
    let payload: String
    
    init(frame: CGRect, text: String, selected: Bool, index: Int, payload: String) {
        self.id = index
        self.padding = 10.0
        
        self.payload = payload
        
        super.init(frame: frame)
        self.text = text
        self.font = UIFont(name: "Magneta-Book", size: 14)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        
        self.clipsToBounds = true
        
        self.isUserInteractionEnabled = true
        
        if selected {
            self.textColor = UIColor.white
            self.backgroundColor = UIColor.black
        }
        
        let maxSize = CGSize(width: UIScreen.main.bounds.width / 2.5, height: 45)
        
        self.size = self.sizeThatFits(maxSize)
        
        self.size.width += self.padding * 2
        self.size.height += self.padding * 2
        
        self.layer.cornerRadius = self.size.height/2
        
        self.drawText(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: self.padding, left: self.padding, bottom: self.padding, right: self.padding)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
