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
        
        let imageData = message.image
        
        if imageData != nil {

            let image = UIImage(data: imageData! as Data)
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: maxMessageSize.width, height: maxMessageSize.height / 2))
            imageView.image = image
            let imageSize = image!.size
            
            if imageSize.width > imageSize.height {
                imageView.frame = CGRect(x: 0, y: 0, width: maxMessageSize.width, height: imageSize.height * maxMessageSize.width / imageSize.width)
            }
            else {
                let computedWidth = imageSize.width * maxMessageSize.height / imageSize.height
                if computedWidth > maxMessageSize.width {
                    imageView.frame = CGRect(x: 0, y: 0, width: maxMessageSize.width, height: imageSize.height * maxMessageSize.width / imageSize.width)
                }
                else {
                    imageView.frame = CGRect(x: 0, y: 0, width: computedWidth, height: maxMessageSize.height)
                }
            }
            returnValue = imageView.frame.size
            
            
            if message.received {
                imageView.frame = CGRect(x: hMargin, y: vMargin, width: returnValue.width, height: returnValue.height)
            }
            else {
                imageView.frame = CGRect(x: UIScreen.main.bounds.width - (returnValue.width + hMargin), y: vMargin, width: returnValue.width, height: returnValue.height)
            }
            self.addSubview(imageView)
            
        }
        else if let body = (message as AnyObject).value(forKeyPath: "body") {
            let text = body as! String
            
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
            
            if message.received {
                label.frame = CGRect(x: hMargin, y: vMargin, width: returnValue.width, height: returnValue.height)
            }
            else {
                label.frame = CGRect(x: UIScreen.main.bounds.width - (returnValue.width + hMargin), y: vMargin, width: returnValue.width, height: returnValue.height)
            }
            
            self.addSubview(label)
            
        }
        
        returnValue.height += vMargin * 2
        return returnValue
    }
    
    
    
}
