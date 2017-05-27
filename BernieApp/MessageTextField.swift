//
//  MessageTextField.swift
//  BernieApp
//
//  Created by Eleve on 22/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class MessageTextField: UITextField, UITextFieldDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.propertiesInit()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - CGFloat(TextFieldHeight), width: UIScreen.main.bounds.width, height: CGFloat(TextFieldHeight)))
        self.propertiesInit()
    }
    
    func propertiesInit() {
        self.delegate = self
        self.placeholder = "Enter text here"
        //self.borderStyle = UITextBorderStyle.line
        self.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        self.layer.borderWidth = 1
        self.returnKeyType = UIReturnKeyType.send
        self.font = UIFont(name: "Magneta-Book", size: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        MessageManager.shared.request(query: self.text!)
                
        return true
    }
}
