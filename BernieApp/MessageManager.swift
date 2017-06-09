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
    
    // Can't init is singleton
    private init() {
        
    }
    
    func request(query: String) {
        
        print("Request")
        
        var requestMessage = Dictionary<String, Any>()
        requestMessage["speech"] = query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        requestMessage["received"] = false
        requestMessage["type"] = 0
        self.processNewMessage(message: requestMessage)
        
        self.httpRequest(query: query)
    }
    
    func httpRequest(query: String) {
        
        print("Requete :", query)
        
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
                    
                    var delay: Double = 0.0
                    
                    for message in messages {
                        self.processNewMessage(message: message)
                        
                        Delay(delay: delay) {
                            self.startWriting()
                        }
                        
                        switch message["type"] as! Int {
                        case 0:
                            let speech = message["speech"] as! String
                            let count = speech.characters.count
                            delay += Double(count) / 20.0
                        default:
                            delay += 4
                        }
                        
                        
                        Delay(delay: delay) {
                            self.endWriting()
                        }
                        
                        delay += 1.0
                    }
                }
            }
        }
    }
    
    
    func startWriting(){
        self.broadcastStartTyping()
    }
    
    func endWriting() {
        self.broadcastStopTyping()
        
        if(self.queueToSave.count > 0) {
            self.saveNextMessage()
        }
    }
    
    func saveNextMessage() {
        let messageToSave = self.queueToSave.removeFirst()
    
        let message = Message(context: self.persistentContainer.viewContext)
        
        if messageToSave["body"] != nil {
            message.body = messageToSave["body"] as? String
        }
        
        if messageToSave["date"] != nil {
            message.date = messageToSave["date"] as? NSDate
        }
        
        if messageToSave["gif"] != nil {
            message.gif = messageToSave["gif"] as! Bool
        }
        
        if messageToSave["highlights"] != nil {
            message.highlights = messageToSave["highlights"] as? NSObject
        }
        
        if messageToSave["image"] != nil {
            message.image = messageToSave["image"] as? NSData
        }
        
        if messageToSave["received"] != nil {
            message.received = messageToSave["received"] as! Bool
        }
        
        if messageToSave["type"] != nil {
            message.type = messageToSave["type"] as! Int16
        }
        
        if messageToSave["replies"] != nil {
            message.replies = messageToSave["replies"] as? NSObject
        }
        
        self.saveContext()
        self.broadcastNewMessage()
}
    
    func processNewMessage(message: Dictionary<String, Any>) {
        let type: Int = message["type"] as! Int
        
        switch type {
        case 0:
            var savedMessage = self.createMessageToSave(message: message)
            
            let body = (message["speech"] as? String)!
            savedMessage["body"] = body
            
            if((savedMessage["body"] as! String) != "") {
                
                self.save(savedMessage: savedMessage)
            }
        //case 1:
        //    print("Rich card")
        case 2:
            var savedMessage = self.createMessageToSave(message: message)
            savedMessage["replies"] = message["replies"]
            self.save(savedMessage: savedMessage)
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
                        
                        self.save(savedMessage: savedMessage)
                        
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
                        
                        self.save(savedMessage: savedMessage)
                    }
                    }.resume()
            }
        //case 4:
        //    print("Custom payload")
        default:
            let savedMessage = self.createMessageToSave(message: message)
            self.save(savedMessage: savedMessage)
        }
    }
    
    func save(savedMessage: Dictionary<String, Any>) {
        self.queueToSave.append(savedMessage)
        if savedMessage["received"] != nil && savedMessage["received"] as! Bool == false {
            self.saveNextMessage()
        }
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
