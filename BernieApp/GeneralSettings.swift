//
//  GeneralSettings.swift
//  BernieApp
//
//  Created by Thomas BOULONGNE on 17/06/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation

// MARK: - Singleton

final class GeneralSettings {
    
    var subscribers: [ThemeSubscriber] = []
    var theme: String = "black"
    
    // Can't init is singleton
    private init() {
        
    }
    
    func subscribe(obj: ThemeSubscriber) -> () -> () {
        let index = self.subscribers.count
        self.subscribers.append(obj)
        
        return { () -> () in
            self.subscribers.remove(at: index)
        }
    }
    
    func broadcastNewTheme(theme: String) {
        for subscriber in self.subscribers {
            subscriber.updateColors(theme: theme)
        }
    }
    
    // MARK: Shared Instance
    
    static let shared = GeneralSettings()

}
