//
//  CarouselCell.swift
//  BernieApp
//
//  Created by Thomas on 6/9/17.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class CarouselCell: UIView {
    var imageUrl: String = ""
    var title: String = ""
    var subTitle: String = ""
    var wrapper: UIView = UIView()
    
    var richcard: Richcard!
    
    var insetMargin: CGFloat = 15
    
    var imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: richcardSize.width, height: richcardSize.height))
    
    var titleLabel: RichcardTitle = RichcardTitle()
    
    var subtitleLabel: RichcardSubtitle = RichcardSubtitle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup(richcard: Richcard) {
        
        self.imageUrl  = richcard.imageUrl!
        self.title     = richcard.title!
        self.subTitle  = richcard.subTitle!
        
        self.richcard = richcard
        
        self.wrapper.frame = CGRect(x: 0, y: 0, width: richcardSize.width, height: richcardSize.height)
        self.wrapper.backgroundColor = .black
        
        self.wrapper.layer.cornerRadius = 10
        self.wrapper.layer.masksToBounds = true
        
        guard let url = URL(string: self.imageUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
                self.wrapper.insertSubview(self.imageView, at: 0)
            }
        }.resume()
        
        self.subtitleLabel.text = self.subTitle
        
        self.subtitleLabel.font = UIFont(name: "NHaasGroteskDSPro-65Md", size: 14)
        self.subtitleLabel.textColor = .white
        
        let subtitleLabelSize = self.subtitleLabel.sizeThatFits(richcardSize)
        
        self.subtitleLabel.frame = CGRect(x: self.insetMargin, y: self.wrapper.bounds.height - self.insetMargin - subtitleLabelSize.height, width: subtitleLabelSize.width, height: subtitleLabelSize.height)
        
        self.wrapper.addSubview(self.subtitleLabel)
        
        
        self.titleLabel.text = self.title
        
        self.titleLabel.backgroundColor = .white
        
        self.titleLabel.font = UIFont(name: "NHaasGroteskDSPro-65Md", size: 20)
        
        let titleLabelSize = self.titleLabel.sizeThatFits(richcardSize)
        
        self.titleLabel.frame = CGRect(x: 15, y: self.wrapper.bounds.height - self.insetMargin - titleLabelSize.height - subtitleLabelSize.height - self.insetMargin/2, width: titleLabelSize.width, height: titleLabelSize.height)
        
        self.wrapper.addSubview(self.titleLabel)
        self.addSubview(self.wrapper)
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tap)
    }
    
    func didTap(sender: UITapGestureRecognizer) {
        (UIApplication.topViewController() as! ViewController).openRichcard(cell: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
