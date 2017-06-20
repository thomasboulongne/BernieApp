//
//  Carousel.swift
//  BernieApp
//
//  Created by Thomas on 6/9/17.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class Carousel : UIScrollView, UIScrollViewDelegate {

    let items: Array<Any>
    
    var page: CGFloat = 0.0
    
    init(frame: CGRect, items: Array<Any>) {
        self.items = items
        super.init(frame: frame)
        
        let cellWitdth = richcardSize.width + richcardMargin * 2
        
        self.contentSize = CGSize(width: cellWitdth * CGFloat(self.items.count), height: richcardSize.height)
        
        self.showsHorizontalScrollIndicator = false
        
        self.isPagingEnabled = true
        
        self.delegate = self
        
        self.clipsToBounds = false
        
        var i: CGFloat = 0
        for item in self.items {
            let rc = item as! Richcard
            let cell = CarouselCell(frame: CGRect(x: i * cellWitdth, y: vMargin, width: cellWitdth, height: richcardSize.height))
            cell.setup(richcard: rc)
            self.addSubview(cell)
            i += 1
        }
        
        for view in self.subviews {
            view.transform = CGAffineTransform(scaleX: richcardScaleDown, y: richcardScaleDown)
        }
        
        self.subviews[Int(self.page)].transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        

        let offset = self.contentOffset.x / self.frame.size.width
        
        if offset >= 0 {
            var nextPage: CGFloat = 0.0
            var percentage: CGFloat = 0.0
            if offset > self.page { // Swiping up in the offset
                nextPage = offset.rounded(.up)
                
                percentage = (nextPage - offset) * (1 - richcardScaleDown)
                
            }
            else {
                nextPage = offset.rounded(.down)
                
                percentage = (offset - nextPage) * (1 - richcardScaleDown)
                
            }
            
            UIView.animate(withDuration: 0.1,
                           animations: {
                            self.subviews[Int(nextPage)].transform = CGAffineTransform(scaleX: 1 - percentage, y: 1 - percentage)
            }
            )
            
            if richcardScaleDown + percentage <= 1{
                UIView.animate(withDuration: 0.1,
                               animations: {
                                self.subviews[Int(self.page)].transform = CGAffineTransform(scaleX: richcardScaleDown + percentage, y: richcardScaleDown + percentage)
                }
                )
            }
                
            if(offset == offset.rounded(.toNearestOrAwayFromZero)){
                
                self.page = offset.rounded()
                
                
                UIView.animate(withDuration: 0.1,
                               animations: {
                                self.subviews[Int(self.page)].transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
