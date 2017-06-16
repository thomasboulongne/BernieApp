//
//  RichcardViewController.swift
//  BernieApp
//
//  Created by Eleve on 14/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class RichcardViewController: UIViewController {
    
    var backgroundImage: BackgroundImageView!
    
    var richcard: Richcard
    
    var card: CardView!
    
    var translateY: CGFloat = 0.0
    
    init(cell: CarouselCell) {
        
        self.richcard = cell.richcard
        
        super.init(nibName: nil, bundle: nil)
        self.backgroundImage = BackgroundImageView(frame: self.view.frame, image: cell.imageView.image!)
        
        self.view.addSubview(self.backgroundImage)
        
        self.view.clipsToBounds = false
        
        self.addCloseButton()
        
        self.addCard()
    }
    
    override func viewDidLoad() {
        
    }
    
    func addCard() {

        let cardWidth = UIScreen.main.bounds.width - hMargin * 2
        let maxSize = CGSize(width: cardWidth - detailsPadding * 2, height: UIScreen.main.bounds.height * 3)
        self.card = CardView()
        
        let arrowWrapper = UIView()
        let arrow = UIButton()
        
        let arrowSize = CGSize(width: 36, height: vMargin)
        
        arrowWrapper.addSubview(arrow)
        
        let arrowWrapperSize = CGSize(width: maxSize.width, height: vMargin + arrowSize.height)
        
        let wrapper = UIView()
        
        wrapper.layer.cornerRadius = detailsPadding
        
        let title = UILabel()
        title.text = self.richcard.title
        title.font = UIFont(name: "NHaasGroteskDSPro-65Md", size: 26)
        title.numberOfLines = 0
        title.textColor = black
        
        
        let titleSize = title.sizeThatFits(maxSize)
        
        let subtitle = UILabel()
        subtitle.text = self.richcard.subTitle
        subtitle.font = UIFont(name: "NHaasGroteskDSPro-65Md", size: 16)
        subtitle.textColor = grey
        
        let subtitleSize = subtitle.sizeThatFits(maxSize)
        
        let desc = UILabel()
        desc.text = self.richcard.desc
        desc.font = UIFont(name: "NHaasGroteskDSPro-65Md", size: 14)
        desc.textColor = brownishgrey
        desc.numberOfLines = 0
        
        let descSize = desc.sizeThatFits(maxSize)
        
        let subItemsView = UIScrollView()
        
        for item in self.richcard.subitem! {
            let subitem = item as! Subitem
            let itemView = UIView()
            let itemImage = UIImageView()
            guard let url = URL(string: subitem.imageUrl!) else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() { () -> Void in
                    itemImage.image = image
                }
                }.resume()
            let itemTitle = UILabel()
            itemTitle.text = subitem.title
            
            itemView.addSubview(itemImage)
            itemView.addSubview(itemTitle)
            
            subItemsView.addSubview(itemView)
        }
        
        let subItemsViewSize = CGSize(width: cardWidth, height: detailsSubitemHeight)

        let ctaButton = CtaButton(frame: CGRect(), text: "Dis m'en plus", padding: detailsPadding, payload: "", maxSize: maxSize)
        
        wrapper.addSubview(title)
        wrapper.addSubview(subtitle)
        wrapper.addSubview(desc)
        wrapper.addSubview(subItemsView)
        wrapper.addSubview(ctaButton)
        
        card.addSubview(arrow)
        card.addSubview(wrapper)
        self.card.addSubview(arrowWrapper)
        
        wrapper.backgroundColor = .white
        
        subItemsView.backgroundColor = .green
        
        let wrapperHeight = titleSize.height + detailsPadding + subtitleSize.height + descSize.height + subItemsViewSize.height + detailsPadding + ctaButton.size.height + detailsPadding
        
        let cardHeight = arrowWrapperSize.height + wrapperHeight
        
        
        arrowWrapper.frame  = CGRect(x: 0, y: 0, width: cardWidth, height: arrowWrapperSize.height)
        
        wrapper.frame       = CGRect(x: 0, y: arrowWrapperSize.height, width: cardWidth, height: wrapperHeight)
        
        let titleY          = detailsPadding
        
        title.frame         = CGRect(x: detailsPadding, y: detailsPadding, width: titleSize.width, height: titleSize.height)
        
        let subtitleY       = titleY + titleSize.height
        
        subtitle.frame      = CGRect(x: detailsPadding, y: subtitleY, width: subtitleSize.width, height: subtitleSize.height)
        
        let descY           = subtitleY + subtitleSize.height
        
        desc.frame          = CGRect(x: detailsPadding, y: descY, width: descSize.width, height: descSize.height)
        
        let subitemsY       = descY + descSize.height
        
        subItemsView.frame  = CGRect(x: 0, y: subitemsY, width: subItemsViewSize.width, height: subItemsViewSize.height)
        
        let buttonWrapperY  = subitemsY + subItemsViewSize.height + detailsPadding
        
        ctaButton.frame     = CGRect(x: cardWidth / 2 - ctaButton.size.width / 2, y: buttonWrapperY, width: ctaButton.size.width, height: ctaButton.size.height)
        
        self.card.frame     = CGRect(x: hMargin, y: UIScreen.main.bounds.height - arrowWrapperSize.height - subitemsY, width: cardWidth, height: cardHeight)
        
        self.translateY = hMargin + subItemsViewSize.height + ctaButton.size.height + detailsPadding
        
        self.card.bottomHeight = self.translateY
        self.card.topHeight = self.card.bounds.height - self.card.bottomHeight
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(showCard))
        swipeUp.direction = .up
        self.card.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(hideCard))
        swipeDown.direction = .down
        self.card.addGestureRecognizer(swipeDown)
        
        self.view.addSubview(self.card)
    }
    
    func showCard(gesture: UISwipeGestureRecognizer) {
        print("swipeUp")
        UIView.animate(withDuration: 0.3, animations: {
            self.card.transform = CGAffineTransform(translationX: 0, y: -self.translateY)
        })
    }
    
    func hideCard(gesture: UISwipeGestureRecognizer) {
        print("swipeDown")
        UIView.animate(withDuration: 0.3, animations: {
            self.card.transform = CGAffineTransform.identity
        })
    }
    
    func addCloseButton() {
        let closeSize: CGFloat = CGFloat(closeButtonHeight)
        let closeButton = IconRoundButton(frame: CGRect(
            x: self.view.frame.width - closeSize * 1.5,
            y: closeSize,
            width: closeSize,
            height: closeSize), iconName: "close")
        closeButton.addTarget(self, action:#selector(self.close), for: .touchUpInside)
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.white.cgColor
        self.view.addSubview(closeButton)
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
