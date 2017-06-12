//
//  Carousel.swift
//  BernieApp
//
//  Created by Thomas on 6/9/17.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class Carousel: UICollectionView, UICollectionViewDataSource {
    
    let layout = CarouselLayout()
    let items: [Dictionary<String,Any>]
    
    init(frame: CGRect, items: [Dictionary<String,Any>]) {
        self.items = items
        super.init(frame: frame, collectionViewLayout: self.layout)
        self.register( CarouselCell.self, forCellWithReuseIdentifier: "cell")
        
        self.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CarouselCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath as IndexPath) as! CarouselCell
        
        let item = self.items[indexPath.row]
        cell.setup(imageUrl: item["imageUrl"] as! String, title: item["title"] as! String, subTitle: item["subTitle"] as! String, desc: item["desc"] as! String, subItems: item["subItems"] as! [Dictionary<String, String>], postback: item["payload"] as! String)
        
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
