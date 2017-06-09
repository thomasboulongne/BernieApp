//
//  ViewController.swift
//  BernieApp
//
//  Created by Eleve on 18/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageManagerSubscriber {
    
    var messages: [Message] = []
    private var tableView: UITableView!
    var scrollView: UIScrollView!
    var textField: UITextField!
    var header: Header!
    
    var unsubscribe = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications()
        
        self.scrollView = UIScrollView(frame: self.view.frame)
        self.view.addSubview(self.scrollView)
        
        let height: CGFloat = UIScreen.main.bounds.height - CGFloat(TextFieldHeight)
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: height))
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
        
        self.scrollView.addSubview(self.tableView)
        
        
        UIApplication.shared.statusBarView?.backgroundColor = .white

        
        self.tableView.register(MessageCell.self, forCellReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.textField = MessageTextField()
        self.scrollView.addSubview(self.textField)
        
        self.tableView.estimatedRowHeight = 50
        
        self.tableView.keyboardDismissMode = .onDrag
        
        self.tableView.allowsSelection = false
        
        self.header = Header(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight))
        self.view.addSubview(self.header)
        
        self.unsubscribe = MessageManager.shared.subscribe(obj: self)
        
        self.onMessagesUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.unsubscribe()
        self.deregisterFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.header.setupGradient()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MessageCell
                
        let message = self.messages[indexPath.row]
        
        cell.setupWithMessage(message: message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let message = self.messages[indexPath.row]
        
        let cell = MessageCell()
        
        let height = cell.setupWithMessage(message: message).height
        
        return height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func onMessagesUpdate() {
        
        self.messages = MessageManager.shared.getMessages()
        
        
        self.tableView.reloadData {
            self.tableViewScrollToBottom(animated: true)
        }
        
    }
    
    func onStartTyping() {
        self.header.startTyping()
    }
    
    func onStopTyping() {
        self.header.stopTyping()
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height)
        self.tableView.setContentOffset(scrollPoint, animated: true)
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        
        self.tableViewScrollToBottom(animated: true)
        
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: contentInsets.bottom), animated: true)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.textField.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
}
