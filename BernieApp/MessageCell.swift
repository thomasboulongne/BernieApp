//
//  MessageLabel.swift
//  BernieApp
//
//  Created by Thomas BOULONGNE on 25/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class MessageCell: UITableViewCell {
    
    func setupWithMessage(message: Message) -> CGSize {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        var returnValue = CGSize(width: 0, height: 0)
        
        if let body = (message as AnyObject).value(forKeyPath: "body") {
            let text = body as! String
        
            let regexp = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)(?:\\.png|\\.jpg|\\.jpeg)"
            
            let range = text.range(of: regexp, options: .regularExpression)
            
            if(range != nil) {
                let imageView = UIImageView()
                imageView.downloadedFrom(link: text)
                self.addSubview(imageView)
            }
            else {
                
                let label = UILabel(frame: CGRect())
                
                label.text = text
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                
                if(message.received) {
                    label.font = UIFont(name: "NHaasGroteskDSPro-65Md", size: 18)
                }
                else {
                    label.font = UIFont(name: "Magneta-Book", size: 16)
                }
                
                returnValue = label.sizeThatFits(CGSize(width: maxMessageSize.width, height: maxMessageSize.height))
                
                returnValue.height += vMargin * 2
                
                if message.received {
                    label.frame = CGRect(x: hMargin, y: vMargin, width: UIScreen.main.bounds.width - hMargin * 2, height: self.bounds.height)
                }
                else {
                    label.frame = CGRect(x: UIScreen.main.bounds.width - (returnValue.width + hMargin), y: vMargin, width: returnValue.width, height: returnValue.height)
                }
                
                self.addSubview(label)
            }
        }
                
        return returnValue
    }
    
    
    
}
