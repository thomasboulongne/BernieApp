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
    var cells: [MessageCell] = []
    
    private var tableView: UITableView!
    var scrollView: UIScrollView!
    var textField: MessageTextField!
    var header: Header!
    var photoButton: IconRoundButton!
    
    var cameraViewController: CameraViewController!
    var toCamera: Bool!
    
    var richcardViewController: RichcardViewController!
    let richcardTransition = RichcardAnimator()
    
    var selectedRichcard: UIView?
    
    var heights: [CGFloat] = []
    
    var unsubscribe = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toCamera = false
        self.registerForKeyboardNotifications()

        self.scrollView = UIScrollView(frame: self.view.frame)
        self.cameraViewController = CameraViewController()
        
        
        self.view.addSubview(self.scrollView)
        
        let height: CGFloat           = UIScreen.main.bounds.height - CGFloat(TextFieldHeight)
        let tableView                 = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: height))
        self.tableView                = tableView
        self.tableView.delegate       = self
        self.tableView.dataSource     = self
        
        self.tableView.separatorStyle = .none
        
        self.tableView.contentInset   = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        
        self.scrollView.addSubview(self.tableView)
        
        self.tableView.register(MessageCell.self, forCellReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view, typically from a nib.
        self.textField = MessageTextField()
        self.scrollView.addSubview(self.textField)
        
        self.tableView.keyboardDismissMode = .onDrag
        
        self.tableView.allowsSelection = false
        
        self.header = Header(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight))
        self.view.addSubview(self.header)
        
        self.header.logo.play(file: "Humeur1-Smile")
        
        self.setColors()
        
        let size: CGFloat = CGFloat(ShortcutButtonHeight)
        let marginY: CGFloat = ( CGFloat(TextFieldHeight) - size ) / 2
        self.photoButton = IconRoundButton(frame: CGRect(x: UIScreen.main.bounds.width - ( marginY * 2 ) - size, y: UIScreen.main.bounds.height - marginY - size, width: size, height: size), iconName: "photo")
        self.photoButton.addTarget(self, action:#selector(self.openCamera), for: .touchUpInside)
        self.photoButton.layer.borderWidth = 1
        self.photoButton.layer.borderColor = UIColor.brnGreyish.cgColor
        self.photoButton.tintColor = UIColor.brnGreyish
        self.scrollView.addSubview(self.photoButton)
        
        self.unsubscribe = MessageManager.shared.subscribe(obj: self)
        
        self.onMessagesUpdate(animated: false)
        
        self.richcardTransition.dismissCompletion = {
            self.selectedRichcard!.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.unsubscribe()
        self.deregisterFromKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.unsubscribe = MessageManager.shared.subscribe(obj: self)
        self.registerForKeyboardNotifications()
        self.setColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.header.setupGradient()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        for cell in tableView.visibleCells {
            let customCell = cell as! MessageCell
            
            if customCell.gif != nil {
                let cellRect = tableView.rectForRow(at: tableView.indexPath(for: cell)!)
                if tableView.bounds.contains(cellRect) {
                    customCell.gif?.startAnimatingGif()
                }
                else {
                    customCell.gif?.stopAnimatingGif()
                }
            }
        }
    }
        
    func setColors() {
        UIApplication.shared.statusBarView?.backgroundColor = themes(theme: GeneralSettings.shared.theme)["whiteBg"]
        
        if GeneralSettings.shared.theme == "black" {
            UIApplication.shared.statusBarStyle = .lightContent
        }
        
        self.scrollView.backgroundColor = themes(theme: GeneralSettings.shared.theme)["whiteBg"]
        self.tableView.backgroundColor = themes(theme: GeneralSettings.shared.theme)["whiteBg"]
        
    }
    
    func openCamera() {
        self.toCamera = true
        
        self.present( self.cameraViewController, animated: true, completion: nil)
    }
    
    func openRichcard(cell: CarouselCell) {
        let richcardViewController = RichcardViewController(cell: cell)
        richcardViewController.transitioningDelegate = self
        
        self.selectedRichcard = cell
        
        self.richcardTransition.originFrame = cell.wrapper.convert(cell.wrapper.frame, to: nil)
        
        self.present(richcardViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MessageCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let message = self.messages[indexPath.row]
        
        (cell as! MessageCell).setupWithMessage(message: message, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height = self.heights[indexPath.row]
        
        return height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func onMessagesUpdate(animated: Bool) {
        
        self.messages = MessageManager.shared.getMessages()
        
        self.heights = []
        
        var i = 0
        for message in self.messages {
            let cell: MessageCell = MessageCell()
            heights.append(cell.setupWithMessage(message: message, index: i).height)
            i += 1
        }
        
        self.tableView.reloadData {
            self.tableViewScrollToBottom(animated: animated)
        }
        
    }
    
    func onStartTyping() {
        self.header.startTyping()
    }
    
    func onStopTyping() {
        self.header.stopTyping()
    }
    
    func playEmotion(file: String) {
        self.header.logo.play(file: file)
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        if self.messages.count > 0 {
            let index: IndexPath = IndexPath(row: self.messages.count-1, section: 0)
            self.tableView.scrollToRow(at: index, at: .bottom, animated: animated)
        }
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
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: contentInsets.bottom), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.textField.resignFirstResponder()
        self.scrollView.isScrollEnabled = false
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.richcardTransition.cell = self.selectedRichcard as! CarouselCell
        
        self.richcardTransition.presenting = true
//        self.selectedRichcard?.isHidden = true
        return self.richcardTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.richcardTransition.presenting = false
        return self.richcardTransition
    }
}
