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
    
    var gif: UIImageView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.isOpaque = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithMessage(message: Message, index: Int) -> CGSize {
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        self.backgroundColor = themes(theme: GeneralSettings.shared.theme)["whiteBg"]!
        
        if self.layer.sublayers != nil {
            for layer in self.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        
//        let type = message.type == 3 ? 0 : message.type
        
        let type = message.type
        
        var returnValue = CGSize(width: 0, height: 0)
        
        switch type {
        case 1:
            returnValue.width = UIScreen.main.bounds.width
            returnValue.height = richcardSize.height + vMargin * 2
            
            let carousel = Carousel(frame: CGRect(x: returnValue.width/2 - (richcardSize.width + richcardMargin * 2)/2, y: 0, width: (richcardSize.width + richcardMargin * 2), height: returnValue.height ), items: message.richcard!.allObjects)
            
            self.addSubview(carousel)
            return returnValue
            
        case 2:
            
            let replies = message.replies as! Array<Dictionary<String, String>>
            
            var offset: CGFloat = hMargin
            var maxHeight: CGFloat = 0.0
            
            let repliesWrapper = UIScrollView()
            
            repliesWrapper.showsHorizontalScrollIndicator = false
            
            let selectedReply = message.selectedReply
            
            for reply in replies {
                var selected = false
                
                if reply["payload"]! == selectedReply {
                    selected = true
                }
                
                let label = QuickReply(frame: CGRect(), text: reply["title"]!, selected: selected, index: index, payload: reply["payload"]!)
                                
                label.frame = CGRect(x: offset, y: vMargin/2, width: label.size.width, height: label.size.height)
                offset += label.size.width + label.padding
                
                if label.size.height > maxHeight {
                    maxHeight = label.size.height
                }
                
                if selectedReply == nil {
                    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapQuickReply))
                    label.addGestureRecognizer(tap)
                }
                
                
                repliesWrapper.addSubview(label)
            }
            
            offset += hMargin / 2
            
            returnValue.height = maxHeight + vMargin * 2
            returnValue.width = UIScreen.main.bounds.width
            
            repliesWrapper.contentSize = CGSize(width: offset, height: maxHeight)
            
            if offset <= returnValue.width {
                repliesWrapper.frame = CGRect(x: returnValue.width / 2 - offset / 2, y: vMargin / 2, width: returnValue.width, height: returnValue.height)
            }
            else {
                repliesWrapper.frame = CGRect(x: 0, y: vMargin / 2, width: returnValue.width, height: returnValue.height)
            }
        
            self.addSubview(repliesWrapper)
            
            let mask = CAGradientLayer();
            mask.frame = CGRect(x: 0, y: 0, width: returnValue.width, height: returnValue.height)
            
            let color1 = themes(theme: GeneralSettings.shared.theme)["whiteBg"]!.cgColor
            let color2 = themes(theme: GeneralSettings.shared.theme)["whiteBg"]?.withAlphaComponent(0).cgColor
            
            mask.colors = [color1, color2!, color2!, color1]
            
            let point1: NSNumber = 0.0
            let point2: CGFloat  = CGFloat(hMargin) / CGFloat(returnValue.width)
            let point3: CGFloat  = 1 - (CGFloat(hMargin) / CGFloat(returnValue.width))
            let point4: NSNumber = 1.0
            
            mask.locations  = [point1, NSNumber(value: Float(point2)), NSNumber(value: Float(point3)), point4]
            
            mask.startPoint = CGPoint(x: 0.0, y: 0.0)
            mask.endPoint   = CGPoint(x: 1.0, y: 0.0)
            
            self.layer.insertSublayer(mask, at: 1)
            return returnValue
        case 3:
            let imageData = message.image
            let image: UIImage
            let imageView: UIImageView
            
            var imageSize: CGSize = CGSize(width: 0, height: 0)
            if message.gif {
//            if false {
                image = UIImage(gifData: imageData! as Data, levelOfIntegrity: 1.0)
                imageView = UIImageView(gifImage: image, manager: gifmanager)
                imageSize = imageView.frameAtIndex(index: 0).size
                
                self.gif = imageView
                imageView.stopAnimatingGif()
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
            let body = (message as AnyObject).value(forKeyPath: "body")
            let text = (body as? String) == nil ? "text not found" : body as! String
            
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
            
            label.textColor = themes(theme: GeneralSettings.shared.theme)["black"]!
            
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
    
    func didTapQuickReply(sender: UITapGestureRecognizer) {
        let view = sender.view as! QuickReply
        
        MessageManager.shared.saveQuickReply(reply: view.payload, index: view.id)
    }
    
}
