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

    let padding = UIEdgeInsets(top: 0, left: hMargin, bottom: 0, right: hMargin);
    
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
        self.addBorder(edges: .top, color: UIColor.brnWhite, thickness: 1)
        self.returnKeyType = UIReturnKeyType.send
        self.font = UIFont(name: "Magneta-Book", size: 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var query = Dictionary<String, Any>()
        query["speech"] = self.text!
        query["type"] = 0
        MessageManager.shared.request(query: query)
        self.text = ""
        return true
    }
}
