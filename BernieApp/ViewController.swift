//
//  ViewController.swift
//  BernieApp
//
//  Created by Eleve on 18/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageManagerSubscriber {
    
    var messages: [Any] = []
    private var tableView: UITableView!
    
    var unsubscribe = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height: CGFloat = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - CGFloat(TextFieldHeight)
        let tableView = UITableView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.height, height: height))
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        
        self.onMessagesUpdate()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view, typically from a nib.
        let textField = MessageTextField()
        self.view.addSubview(textField)
        
        self.unsubscribe = MessageManager.shared.subscribe(obj: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.unsubscribe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        
        let message = self.messages[indexPath.row]
        
        cell.textLabel?.text = (message as AnyObject).value(forKeyPath: "body") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func onMessagesUpdate() {
        
        self.messages = MessageManager.shared.getMessages()
        
        self.tableView.reloadData()
        
        self.tableViewScrollToBottom(animated: true)
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        let scrollPoint = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height)
        self.tableView.setContentOffset(scrollPoint, animated: true)
    }
}
