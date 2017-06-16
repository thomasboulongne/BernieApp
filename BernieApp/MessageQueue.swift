//
//  MessageQueue.swift
//  BernieApp
//
//  Created by Eleve on 14/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import CoreData

class MessageQueue {
    
    var queue: [Dictionary<String, Any>] = []
    
    var delays: [Dictionary<String, Double>] = []
    
    let id: Int
    
    init() {
        self.id = Date().hashValue
    }
    
    func addElement(elt: Dictionary<String, Any>, startDelay: Double, endDelay: Double) {
        self.queue.append(elt)
        var delays = Dictionary<String, Double>()
        delays["start"] = startDelay
        delays["end"] = endDelay
        self.delays.append(delays)
    }
    
    func updateMessage(index: Int, message: Dictionary<String, Any>) {
        
        print("update: ", message)
        print("index: ", index)
        
        self.queue[index] = message
        self.queue[index]["__readyToSave__"] = true
        
        for message in self.queue {
            if message["__readyToSave__"] == nil {
               return
            }
        }
        
        self.consume()
    }
    
    func consume() {
        var i = 0
        
        for messageToSave in self.queue {
            if (messageToSave["received"] != nil) && (messageToSave["received"] as? Bool == true) {
                Delay(delay: self.delays[i]["start"]!) {
                    self.startWriting()
                    
                    var message = Message(context: MessageManager.shared.persistentContainer.viewContext)
                    
                    message = self.convertMessage(dict: messageToSave, message: message)
                }
                
                Delay(delay: self.delays[i]["end"]!) {
                    self.endWriting()
                    MessageManager.shared.saveContext()
                    MessageManager.shared.broadcastNewMessage()
                }
            }
            else {
                
                var message = Message(context: MessageManager.shared.persistentContainer.viewContext)
                
                message = self.convertMessage(dict: messageToSave, message: message)
                
                MessageManager.shared.saveContext()
                MessageManager.shared.broadcastNewMessage()
            }
            i += 1
        }
    }
    
    func convertMessage(dict: Dictionary<String, Any>, message: Message) -> Message {
        
        for key in message.entity.attributesByName.keys {
            message.setValue(dict[key], forKey: key)
        }
        
        if dict["richcards"] != nil {
            
            for richcard in dict["richcards"] as! Array<Dictionary<String, Any>> {
                let rc = Richcard(context: MessageManager.shared.persistentContainer.viewContext)
                
                for key in rc.entity.attributesByName.keys {
                    rc.setValue(richcard[key], forKey: key)
                }
                
                if richcard["subitems"] != nil {
                    
                    for subitem in richcard["subitems"] as! Array<Dictionary<String, Any>> {
                        let si = Subitem(context: MessageManager.shared.persistentContainer.viewContext)
                        for key in si.entity.attributesByName.keys {
                            si.setValue(subitem[key], forKey: key)
                        }
                        
                        si.richcard = rc
                        
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
        return message
    }
    
    
    func startWriting(){
        MessageManager.shared.broadcastStartTyping()
    }
    
    func endWriting() {
        MessageManager.shared.broadcastStopTyping()
    }
}
