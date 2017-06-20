//
//  MessageTextField.swift
//  BernieApp
//
//  Created by Eleve on 22/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

class MessageTextField: UIView, UITextViewDelegate {

    let padding = UIEdgeInsets(top: hMargin, left: hMargin, bottom: hMargin, right: hMargin + takePhotoButtonHeight);
    
    var TextView: UITextView!
    
    let rect: CGRect
    
    let placeholderText = "Aa"
    
    override init(frame: CGRect) {
        self.rect = frame
        
        super.init(frame: self.rect)
        
        self.propertiesInit()
    }
    
    init() {
        self.rect = CGRect(x: 0, y: UIScreen.main.bounds.height - CGFloat(TextFieldHeight), width: UIScreen.main.bounds.width, height: CGFloat(TextFieldHeight))
        super.init(frame: self.rect)
        self.propertiesInit()
    }
    
    func propertiesInit() {
        let textRect = CGRect(x: 0, y: 0, width: self.rect.width, height: self.rect.height)
        self.TextView = UITextView(frame: textRect, textContainer: nil)
//        self.TextView.isScrollEnabled = false
        
        self.TextView.delegate = self
        self.TextView.text = placeholderText
        self.TextView.textColor = UIColor.lightGray
        
        self.TextView.isEditable = true
        
        if GeneralSettings.shared.theme == "black" {
            self.TextView.keyboardAppearance = .dark
        }
            
        
        self.addBorder(edges: .top, color: UIColor.brnWhite, thickness: 1)
        self.TextView.returnKeyType = UIReturnKeyType.send
        
        self.TextView.font = UIFont.brnUserTextSentFont()
        
        self.TextView.backgroundColor = .clear
        
        self.TextView.textContainerInset = self.padding
        
        self.TextView.contentSize = CGSize(width: self.TextView.contentSize.width, height: self.TextView.contentSize.height - 2 * hMargin)
        
        self.TextView.text = self.placeholderText
        self.TextView.textColor = UIColor.lightGray
        
        
        self.addSubview(self.TextView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.TextView.textColor == UIColor.lightGray {
            self.TextView.text = nil
            self.TextView.textColor = themes(theme: GeneralSettings.shared.theme)["black"]
        }
        
        let newPosition = self.TextView.endOfDocument
        self.TextView.selectedTextRange = self.TextView.textRange(from: newPosition, to: newPosition)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            
            self.TextView.text = self.placeholderText
            self.TextView.textColor = UIColor.lightGray
            
            self.TextView.selectedTextRange = self.TextView.textRange(from: self.TextView.beginningOfDocument, to: self.TextView.beginningOfDocument)
            self.TextView.contentSize = CGSize(width: self.TextView.contentSize.width, height: self.TextView.contentSize.height - 2 * hMargin)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText = self.TextView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            self.TextView.text = self.placeholderText
            self.TextView.textColor = UIColor.lightGray
            
            self.TextView.selectedTextRange = self.TextView.textRange(from: self.TextView.beginningOfDocument, to: self.TextView.beginningOfDocument)
            self.TextView.contentSize = CGSize(width: self.TextView.contentSize.width, height: self.TextView.contentSize.height - 2 * hMargin)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if self.TextView.textColor == UIColor.lightGray && !text.isEmpty {
            self.TextView.text = nil
            self.TextView.textColor = themes(theme: GeneralSettings.shared.theme)["black"]
        }
        
        if text == "\n" {
            
            var query = Dictionary<String, Any>()
            query["speech"] = self.TextView.text!
            query["type"] = 0
            MessageManager.shared.request(query: query)
            
            self.TextView.text = self.placeholderText
            self.TextView.textColor = UIColor.lightGray
            
            self.TextView.selectedTextRange = self.TextView.textRange(from: self.TextView.beginningOfDocument, to: self.TextView.beginningOfDocument)
            
            self.TextView.contentSize = CGSize(width: self.TextView.contentSize.width, height: self.TextView.contentSize.height - 2 * hMargin)
            
            self.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
