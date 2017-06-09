//
//  CarouselCell.swift
//  BernieApp
//
//  Created by Thomas on 6/9/17.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class CarouselCell: UICollectionViewCell {
    var imageUrl: String = ""
    var title: String = ""
    var subTitle: String = ""
    var desc: String = ""
    var subItems: [Dictionary<String, String>] = []
    var postback: String = ""
    
    func setup(imageUrl: String, title: String, subTitle: String, desc: String, subItems: [Dictionary<String, String>], postback: String) {
        self.imageUrl  = imageUrl
        self.title     = title
        self.subTitle  = subTitle
        self.desc      = desc
        self.subItems  = subItems
        self.postback  = postback
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
