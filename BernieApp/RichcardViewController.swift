//
//  RichcardViewController.swift
//  BernieApp
//
//  Created by Eleve on 14/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class RichcardViewController: UIViewController {
    
    var backgroundImage: BackgroundImageView!
    
    var richcard: Richcard
    
    var card: CardView!
    
    var cardWidth: CGFloat = 0
    
    var subItemsView = UIView()
    
    var translateY: CGFloat = 0.0
    
    init(cell: CarouselCell) {
        
        UIApplication.shared.statusBarView?.backgroundColor = .clear
        
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

        self.cardWidth = UIScreen.main.bounds.width - hMargin * 2
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
        title.font = UIFont.brnH2Font()
        title.numberOfLines = 0
        title.textColor = UIColor.brnBlack
        
        
        let titleSize = title.sizeThatFits(maxSize)
        
        let subtitle = UILabel()
        subtitle.text = self.richcard.subTitle
        subtitle.font = UIFont.brnSubhead1Font()
        subtitle.textColor = UIColor.brnWarmGrey
        
        let subtitleSize = subtitle.sizeThatFits(maxSize)
        
        let desc = UILabel()
        desc.text = self.richcard.desc
        desc.font = UIFont.brnBodyFont()
        desc.textColor = UIColor.brnBrownishGrey
        desc.numberOfLines = 0
        
        let descSize = desc.sizeThatFits(maxSize)
        
        let subItemsViewSize = self.addSubitems(superview: wrapper)
        
        let ctaButton = CtaButton(frame: CGRect(), text: "Dis m'en plus", padding: detailsPadding, payload: "", maxSize: maxSize)
        
        wrapper.addSubview(title)
        wrapper.addSubview(subtitle)
        wrapper.addSubview(desc)
        wrapper.addSubview(ctaButton)
        
        card.addSubview(arrow)
        card.addSubview(wrapper)
        self.card.addSubview(arrowWrapper)
        
        wrapper.backgroundColor = .white
        
        let wrapperHeight = titleSize.height + detailsPadding + subtitleSize.height + detailsPadding + descSize.height + detailsPadding + subItemsViewSize.height + detailsPadding + ctaButton.size.height + detailsPadding
        
        let cardHeight = arrowWrapperSize.height + wrapperHeight
        
        
        arrowWrapper.frame  = CGRect(x: 0, y: 0, width: self.cardWidth, height: arrowWrapperSize.height)
        
        wrapper.frame       = CGRect(x: 0, y: arrowWrapperSize.height, width: self.cardWidth, height: wrapperHeight)
        
        let titleY          = detailsPadding
        
        title.frame         = CGRect(x: detailsPadding, y: detailsPadding, width: titleSize.width, height: titleSize.height)
        
        let subtitleY       = titleY + titleSize.height
        
        subtitle.frame      = CGRect(x: detailsPadding, y: subtitleY, width: subtitleSize.width, height: subtitleSize.height)
        
        let descY           = subtitleY + subtitleSize.height + detailsPadding
        
        desc.frame          = CGRect(x: detailsPadding, y: descY, width: descSize.width, height: descSize.height)
        
        let subitemsY       = descY + descSize.height + detailsPadding
        
        subItemsView.frame  = CGRect(x: 0, y: subitemsY, width: subItemsViewSize.width, height: subItemsViewSize.height)
        
        let buttonWrapperY  = subitemsY + subItemsViewSize.height + detailsPadding
        
        ctaButton.frame     = CGRect(x: self.cardWidth / 2 - ctaButton.size.width / 2, y: buttonWrapperY, width: ctaButton.size.width, height: ctaButton.size.height)
        
        self.card.frame     = CGRect(x: hMargin, y: UIScreen.main.bounds.height - arrowWrapperSize.height - subitemsY, width: self.cardWidth, height: cardHeight)
        
        self.translateY = hMargin + subItemsViewSize.height + ctaButton.size.height + detailsPadding
        
        self.card.bottomHeight = self.translateY
        self.card.topHeight = self.card.bounds.height - self.card.bottomHeight
        
        self.subItemsView.addBorder(edges: [.top, .bottom], color: UIColor.brnWhite, thickness: 2)
        
        
        
        ctaButton.isUserInteractionEnabled = true
        let ctaButtonTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ctaPostback))
        ctaButton.addGestureRecognizer(ctaButtonTap)
        
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(showCard))
        swipeUp.direction = .up
        self.card.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(hideCard))
        swipeDown.direction = .down
        self.card.addGestureRecognizer(swipeDown)
        
        self.view.addSubview(self.card)
    }
    
    func addSubitems(superview: UIView) -> CGSize {
        self.subItemsView = UIView()
        let subItemsScrollView = UIScrollView()
        
        let titleLabel = UILabel()
        
        titleLabel.text = self.richcard.subitemtitle
        
        titleLabel.font = UIFont.brnH7Font()
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: self.cardWidth, height: 20))
        
        titleLabel.frame = CGRect(x: detailsPadding, y: detailsPadding, width: titleSize.width, height: titleSize.height)
        
        self.subItemsView.addSubview(titleLabel)
        
        var i: Int = 0
        var offset: CGFloat = detailsPadding - richcardMargin
        
        for item in self.richcard.subitem! {
            let subitem = item as! Subitem
            let itemView = ItemView(frame: CGRect.zero, postback: subitem.postback!)
            let itemImage = UIImageView()
            itemImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            itemImage.layer.cornerRadius = 5
            
            itemImage.contentMode = .scaleAspectFill
            
            itemImage.layer.masksToBounds = true
            
            let url = URL(string: subitem.imageUrl!)!
            itemImage.af_setImage(withURL: url)
            let itemTitle = UILabel()
            
            itemTitle.text = subitem.title
            
            itemTitle.numberOfLines = 2
            
            itemTitle.font = UIFont.brnSmallFont()
            
            itemTitle.frame = CGRect(x: 0, y: itemImage.bounds.height + 3, width: 60, height: 26)
            
            itemView.addSubview(itemImage)
            itemView.addSubview(itemTitle)
            
            let itemWidth: CGFloat = 60
            let itemOffsetWidth: CGFloat = richcardMargin * 2 + itemWidth
            
            itemView.frame = CGRect(x: richcardMargin + offset, y: detailsSubitemHeight/2 - itemImage.bounds.height / 2, width: itemWidth, height: itemImage.bounds.height + 3 + itemTitle.frame.height)
            
            offset += itemOffsetWidth
            i += 1
            
            let subitemTap = UITapGestureRecognizer(target: self, action: #selector(subItemPostback))
            itemView.addGestureRecognizer(subitemTap)
            
            subItemsScrollView.addSubview(itemView)
        }
        
        subItemsScrollView.contentSize.width = offset + detailsPadding - richcardMargin
        
        subItemsScrollView.frame = CGRect(x: 0, y: 0, width: self.cardWidth, height: detailsSubitemHeight)
        
        subItemsScrollView.showsHorizontalScrollIndicator = false
        
        let subItemsViewSize = CGSize(width: cardWidth, height: detailsSubitemHeight)
        
        self.subItemsView.clipsToBounds = true
        
        self.subItemsView.addSubview(subItemsScrollView)
        
        superview.addSubview(subItemsView)

        return subItemsViewSize
    }
    
    func subItemPostback(sender: UITapGestureRecognizer) {
        let si = sender.view as! ItemView
        
        self.close(completion: {
            var request = Dictionary<String, Any>()
            request["type"] = 0
            request["speech"] = si.postback
            MessageManager.shared.request(query: request)
        })
    }
    
    func ctaPostback(sender: UITapGestureRecognizer) {
        self.close(completion: {
            var request = Dictionary<String, Any>()
            request["type"] = 0
            request["speech"] = self.richcard.postback
            MessageManager.shared.request(query: request)
        })
    }
    
    func showCard(gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.card.transform = CGAffineTransform(translationX: 0, y: -self.translateY)
        })
    }
    
    func hideCard(gesture: UISwipeGestureRecognizer) {
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
        closeButton.addTarget(self, action:#selector(self.noPostback), for: .touchUpInside)
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.white.cgColor
        self.view.addSubview(closeButton)
    }
    
    func noPostback() {
        self.close {}
    }
    
    func close(completion: @escaping (()->Void)) {
        self.dismiss(animated: true, completion: completion)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ItemView: UIView {
    let postback: String
    init(frame: CGRect, postback: String) {
        self.postback = postback
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
