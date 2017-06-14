//
//  MessageManager.swift
//  BernieApp
//
//  Created by Eleve on 19/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import UIKit

import SwiftyGif

// MARK: - Singleton

final class MessageManager {
    
    var subscribers: [MessageManagerSubscriber] = []
    
    var queueToSave: [Dictionary<String, Any>] = []
    
    var delays: [Dictionary<String, Double>] = []
    
    var count: Int = 0
    
    // Can't init is singleton
    private init() {
        
    }
    
    func request(query: String) {
        
        var requestMessage = Dictionary<String, Any>()
        requestMessage["speech"] = query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        requestMessage["received"] = false
        requestMessage["type"] = 0
        self.count = 0
        self.queueToSave = [requestMessage]
        self.processNewMessage(message: requestMessage, index: 0)
        
        self.httpRequest(query: query)
    }
    
    func httpRequest(query: String) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + APIAI_Token,
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = [
            "query": query,
            "lang": APIAI_Lang,
            "sessionId": "somerandomthing"
        ]
        
        Alamofire.request("https://api.api.ai/v1/query?v=20150910", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                let JSON = value as! Dictionary<String, Any>
                if(JSON["result"] != nil) {
                    let result = JSON["result"] as! Dictionary<String, Any>
                    let fulfillment = result["fulfillment"] as! Dictionary<String, Any>
                    let messages = fulfillment["messages"] as! Array<Dictionary<String, Any>>
                    
                    self.queueToSave = []
                    self.count = 0
                    var elements: [Dictionary<String, Any>] = []
                    
                    for message in messages {
                        if message["type"] as! Int == 1 {
                            elements.append(message)
                        }
                        else {
                            self.queueToSave.append(message)
                        }
                    }
                    
                    var richcards = Dictionary<String,Any>()
                    richcards["type"] = 1
                    richcards["richcards"] = elements
                    if richcards.count > 0 {
                        self.queueToSave.append(richcards)
                    }
                    
                    var delay: Double = 0.0
                    
                    var i = 0
                    
                    self.delays = []
                    
                    for message in self.queueToSave {
                        self.processNewMessage(message: message, index: i)
                        
                        var delayTimes = Dictionary<String, Double>()
                        
                        delayTimes["start"] = delay
                        
                        switch message["type"] as! Int {
                        case 0:
                            let speech = message["speech"] as! String
                            let count = speech.characters.count
                            delay = delay + Double(count) / 15.0
                        default:
                            delay = delay + 2
                        }
                        
                        delayTimes["duration"] = delay
                        
                        self.delays.append(delayTimes)
                        
                        delay = delay + 2.0
                        
                        i = i+1
                    }
                }
            }
        }
    }
    
    func processNewMessage(message: Dictionary<String, Any>, index: Int) {
        let type: Int = message["type"] as! Int
        
        switch type {
        case 0:
            var savedMessage = self.createMessageToSave(message: message)
            
            let body = (message["speech"] as? String)!
            savedMessage["body"] = body
            
            if((savedMessage["body"] as! String) != "") {
                self.save(savedMessage: savedMessage, index: index)
            }
        case 1:
            var savedMessage = self.createMessageToSave(message: message)
            var richcards = Array<Dictionary<String, Any>>()
            
            for rc in message["richcards"] as! Array<Dictionary<String, Any>> {
                var richcard = Dictionary<String, Any>()
                
                richcard["title"] = rc["title"] as! String
                richcard["subTitle"] = rc["subtitle"] as! String
                richcard["imageUrl"] = rc["imageUrl"] as! String
                let button = rc["buttons"] as! Array<Dictionary<String, String>>
                richcard["postback"] = button[0]["postback"]!
                
                richcard["desc"] = "Most famous Adele look-alike in the LoL game"
                
                richcards.append(richcard)
            }
            
            savedMessage["richcards"] = richcards
            
            self.save(savedMessage: savedMessage, index: index)
        case 2:
            var savedMessage = self.createMessageToSave(message: message)
            savedMessage["replies"] = message["replies"]
            self.save(savedMessage: savedMessage, index: index)
        case 3:
            let body = message["imageUrl"] as! String
            let regexpImg = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)(?:\\.png|\\.jpg|\\.jpeg)"
            let regexpGif = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)(?:\\.gif)"
            let rangeImg = body.range(of: regexpImg, options: .regularExpression)
            let rangeGif = body.range(of: regexpGif, options: .regularExpression)
            
            if rangeImg != nil { // Message is an image
                
                guard let url = URL(string: body) else { return }
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() { () -> Void in
                        
                        
                        var savedMessage = self.createMessageToSave(message: message)
                        
                        let imageData = UIImagePNGRepresentation(image)
                        
                        savedMessage["image"] = imageData! as NSData
                        
                        self.save(savedMessage: savedMessage, index: index)
                        
                    }
                    }.resume()
            }
            else if rangeGif != nil {
                
                guard let url = URL(string: body) else { return }
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil
                        else { return }
                    DispatchQueue.main.async() { () -> Void in
                        
                        
                        var savedMessage = self.createMessageToSave(message: message)
                        
                        savedMessage["image"] = data as NSData
                        
                        savedMessage["gif"] = true
                        
                        self.save(savedMessage: savedMessage, index: index)
                    }
                    }.resume()
            }
            //case 4:
        //    print("Custom payload")
        default:
            let savedMessage = self.createMessageToSave(message: message)
            self.save(savedMessage: savedMessage, index: index)
        }
    }
    
    func save(savedMessage: Dictionary<String, Any>, index: Int) {
        self.queueToSave[index] = savedMessage
        
        self.count += 1
        if self.count == self.queueToSave.count {
            self.consumeMessagesQueue()
        }
    }
    
    
    func startWriting(){
        self.broadcastStartTyping()
    }
    
    func endWriting() {
        self.broadcastStopTyping()
    }
    
    func consumeMessagesQueue() {
        
        var i = 0
        for messageToSave in queueToSave {
            if (messageToSave["received"] != nil) && (messageToSave["received"] as? Bool == true) {
                Delay(delay: self.delays[i]["start"]!) {
                    self.startWriting()
                    
                    let message = Message(context: self.persistentContainer.viewContext)
                    
                    for key in message.entity.attributesByName.keys {
                        message.setValue(messageToSave[key], forKey: key)
                    }
                    
                    if messageToSave["richcards"] != nil {
                        
                        for richcard in messageToSave["richcards"] as! Array<Dictionary<String, Any>> {
                            let rc = Richcard(context: self.persistentContainer.viewContext)
                           
                            for key in rc.entity.attributesByName.keys {
                                rc.setValue(richcard[key], forKey: key)
                            }
                            
                            if richcard["subitems"] != nil {
                                for subitem in richcard["subitems"] as! Array<Dictionary<String, Any>> {
                                    let si = Subitem(context: self.persistentContainer.viewContext)
                                    for key in si.entity.attributesByName.keys {
                                        si.setValue(subitem[key], forKey: key)
                                    }
                                    
                                    rc.subitem?.adding(si)
                                }
                            }
                            else {
                                rc.subitem = []
                            }
                            
                            rc.message = message
                            
                            message.richcard?.adding(rc)
                        }
                    }
                }
                
                Delay(delay: self.delays[i]["duration"]!) {
                    self.endWriting()
                    self.saveContext()
                    self.broadcastNewMessage()
                }
            }
            else {
                
                let message = Message(context: self.persistentContainer.viewContext)
                
                for key in message.entity.attributesByName.keys {
                    message.setValue(messageToSave[key], forKey: key)
                }
                
                if messageToSave["richcards"] != nil {
                    
                    for richcard in messageToSave["richcards"] as! Array<Dictionary<String, Any>> {
                        let rc = Richcard(context: self.persistentContainer.viewContext)
                        
                        for key in rc.entity.attributesByName.keys {
                            rc.setValue(richcard[key], forKey: key)
                        }
                        
                        if richcard["subitems"] != nil {
                            for subitem in richcard["subitems"] as! Array<Dictionary<String, Any>> {
                                let si = Subitem(context: self.persistentContainer.viewContext)
                                for key in si.entity.attributesByName.keys {
                                    si.setValue(subitem[key], forKey: key)
                                }
                                
                                rc.subitem?.adding(si)
                            }
                        }
                        else {
                            rc.subitem = []
                        }
                        
                        rc.message = message
                        
                        message.richcard?.adding(rc)
                    }
                }
                self.saveContext()
                self.broadcastNewMessage()
            }
            i += 1
        }
        
        self.queueToSave = []
        
    }
    
    func saveQuickReply(reply: String, index: Int) {
        let message = self.getMessages()[index]
        message.selectedReply = reply
        self.saveContext()
        self.broadcastNewMessage()
        self.httpRequest(query: reply)
    }
    
    func createMessageToSave(message: Dictionary<String, Any>) -> Dictionary<String, Any> {
        
        var savedMessage = Dictionary<String, Any>()
        
        let tempMessage = Message(entity: NSEntityDescription.entity(forEntityName: "Message", in: self.persistentContainer.viewContext)!, insertInto: nil)
        tempMessage.received = false
        tempMessage.type = 0
        tempMessage.body = "in yo ass adele"
        
        
        if let received = message["received"] {
            savedMessage["received"] = received as! Bool
        }
        else {
            savedMessage["received"] = true
        }
        
        savedMessage["date"] = NSDate()
        
        savedMessage["type"] = (Int16(message["type"] as! Int))
        
        return savedMessage
    }
    
    func broadcastNewMessage() {
        for subscriber in self.subscribers {
            subscriber.onMessagesUpdate()
        }
    }
    
    func broadcastStartTyping() {
        for subscriber in self.subscribers {
            subscriber.onStartTyping()
        }
    }
    
    func broadcastStopTyping() {
        for subscriber in self.subscribers {
            subscriber.onStopTyping()
        }
    }
    
    func getMessages() -> Array<Message> {
        

        var history: Array<Message> = []
        
        do {
            history = try self.persistentContainer.viewContext.fetch(Message.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
        return history
    }
    
    func subscribe(obj: MessageManagerSubscriber) -> () -> () {
        let index = self.subscribers.count
        self.subscribers.append(obj)
        
        return { () -> () in
            self.subscribers.remove(at: index)
        }
    }
    
    /*func unsubscribe(obj: MessageManagerSubscriber) {
        self.subscribers.remove(at: self.subscribers.index(of: obj))
    }*/
    
    // MARK: Shared Instance
    
    static let shared = MessageManager()
    
    // MARK: Local Variable
    
    var emptyStringArray : [String] = []
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
