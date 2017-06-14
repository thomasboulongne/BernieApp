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
    
    var queues: [MessageQueue] = []
    
    // Can't init is singleton
    private init() {
        
    }
    
    func request(query: Dictionary<String, Any>) {
        var requestMessage = query
        if query["speech"] != nil {
            requestMessage["speech"] = (query["speech"] as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        requestMessage["received"] = false
        let queue = MessageQueue()
        self.queues.append(queue)
        queue.addElement(elt: requestMessage, startDelay: 0, endDelay: 0)
        self.processNewMessage(message: requestMessage, index: 0, queueIndex: self.queues.count - 1)
        
        if requestMessage["imageUrl"] != nil {
            self.httpRequest(query: requestMessage["imageUrl"] as! String)
        }
        else {
            self.httpRequest(query: requestMessage["speech"] as! String)
        }
        
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
      
                    var treatedMessages: Array<Dictionary<String, Any>> = []
                    
                    
                    var richcards: [Dictionary<String, Any>] = []
                    
                    print(messages)
                    for message in messages {
                        if message["type"] as! Int == 1 {
                            richcards.append(message)
                        }
                        else {
                            if message["type"] as! Int == 0 {
                                if message["speech"] as! String != "" {
                                    treatedMessages.append(message)
                                }
                            }
                            else {
                                treatedMessages.append(message)
                            }
                        }
                    }
                    
                    var richcardsMessage = Dictionary<String,Any>()
                    richcardsMessage["type"] = 1
                    richcardsMessage["richcards"] = richcards
                    if richcards.count > 0 {
                        treatedMessages.append(richcardsMessage)
                    }
                    
                    var delay: Double = 0.0
                    
                    let queue = MessageQueue()
                    self.queues.append(queue)
                    
                    var i = 0
                    
                    for message in treatedMessages {
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
                        
                        delayTimes["end"] = delay
                        
                        queue.addElement(elt: message, startDelay: delayTimes["start"]!, endDelay: delayTimes["end"]!)
                        
                        self.processNewMessage(message: message, index: i, queueIndex: self.queues.count - 1)
                        
                        delay = delay + 2.0
                        
                        i = i+1
                    }
                }
            }
        }
    }
    
    func processNewMessage(message: Dictionary<String, Any>, index: Int, queueIndex: Int) {
        let type: Int = message["type"] as! Int
        
        switch type {
        case 0:
            var savedMessage = self.createMessageToSave(message: message)
            
            let body = (message["speech"] as? String)!
            savedMessage["body"] = body
            
            if (savedMessage["body"] as! String) != "" {
                self.save(savedMessage: savedMessage, index: index, queueIndex: queueIndex)
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
            
            self.save(savedMessage: savedMessage, index: index, queueIndex: queueIndex)
        case 2:
            var savedMessage = self.createMessageToSave(message: message)
            savedMessage["replies"] = message["replies"]
            self.save(savedMessage: savedMessage, index: index, queueIndex: queueIndex)
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
                        
                        self.save(savedMessage: savedMessage, index: index, queueIndex: queueIndex)
                        
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
                        
                        self.save(savedMessage: savedMessage, index: index, queueIndex: queueIndex)
                    }
                    }.resume()
            }
            //case 4:
        //    print("Custom payload")
        default:
            let savedMessage = self.createMessageToSave(message: message)
            self.save(savedMessage: savedMessage, index: index, queueIndex: queueIndex)
        }
    }
    
    func save(savedMessage: Dictionary<String, Any>, index: Int, queueIndex: Int) {
        self.queues[queueIndex].updateMessage(index: index, message: savedMessage)
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
