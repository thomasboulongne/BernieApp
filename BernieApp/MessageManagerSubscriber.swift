//
//  MessageManagerSubscriber.swift
//  BernieApp
//
//  Created by Eleve on 24/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation

protocol MessageManagerSubscriber {
    func onMessagesUpdate()
    func onStartTyping()
    func onStopTyping()
    func playEmotion(file: String)
}
