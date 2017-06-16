//
//  MessageTextField.swift
//  BernieApp
//
//  Created by Eleve on 22/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class MessageTextField: UITextView, UITextViewDelegate {

    let padding = UIEdgeInsets(top: hMargin, left: hMargin, bottom: hMargin, right: hMargin);
    
    init(frame: CGRect) {
        let textViewRect = frame
        
        super.init(frame: textViewRect, textContainer: nil)
        self.propertiesInit()
    }
    
    init() {
        let textViewRect = CGRect(x: 0, y: UIScreen.main.bounds.height - CGFloat(TextFieldHeight), width: UIScreen.main.bounds.width - hMargin - takePhotoButtonHeight, height: CGFloat(TextFieldHeight))
        super.init(frame: textViewRect, textContainer: nil)
        self.propertiesInit()
    }
    
    func propertiesInit() {
        self.delegate = self
        self.text = "Aa"
        self.textColor = UIColor.lightGray
        
        self.isEditable = true
        
        self.addBorder(edges: .top, color: UIColor.brnWhite, thickness: 1)
        self.returnKeyType = UIReturnKeyType.send
        self.font = UIFont.brnUserTextSentFont()
        
        self.textContainerInset = self.padding
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.text = nil
        self.textColor = UIColor.brnBlack
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            var query = Dictionary<String, Any>()
            query["speech"] = self.text!
            query["type"] = 0
            MessageManager.shared.request(query: query)
            self.resignFirstResponder()
        }
        
        return true
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        self.text = "Aa"
        self.textColor = UIColor.lightGray
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
