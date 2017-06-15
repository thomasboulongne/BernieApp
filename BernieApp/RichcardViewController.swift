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
    
    init(cell: CarouselCell) {
        
        super.init(nibName: nil, bundle: nil)
        self.backgroundImage = BackgroundImageView(frame: self.view.frame, image: cell.imageView.image!)
        
        self.view.addSubview(self.backgroundImage)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        self.view.addGestureRecognizer(tap)
        
        self.view.clipsToBounds = false
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
