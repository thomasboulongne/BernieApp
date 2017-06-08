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
        
        switch message.type {
        case 1:
            //print("Rich card display")
            return returnValue
        case 2:
            //print("quick reply display")
            print(message)
            /*let replies = message.replies as! Array<String>
            for reply in replies {
                print(reply)
            }*/
            return returnValue
        case 3:
            let imageData = message.image
            let image: UIImage
            let imageView: UIImageView
            
            var imageSize: CGSize = CGSize(width: 0, height: 0)
            if message.gif {
                image = UIImage(gifData: imageData! as Data)
                imageView = UIImageView(gifImage: image, manager: gifmanager)
                imageSize = imageView.frameAtIndex(index: 0).size
            }
            else {
                image = UIImage(data: imageData! as Data)!
                imageView = UIImageView(image: image)
                imageSize = image.size
            }
            
            imageView.layer.cornerRadius = 5
            imageView.layer.masksToBounds = true
            
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
            
        default:
            //print("Default")
            let body = (message as AnyObject).value(forKeyPath: "body")
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
