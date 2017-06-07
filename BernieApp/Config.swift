//
//  Config.swift
//  BernieApp
//
//  Created by Eleve on 19/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit
import SwiftyGif

let APIAI_Token = "a881a3adcd5642e3b9ce925de1479dae"
let APIAI_Lang  = "fr"

let TextFieldHeight = 60.0

let hMargin: CGFloat = 30.0
let vMargin: CGFloat = 10.0

let headerHeight: CGFloat = 100.0

let logoSize: CGFloat = headerHeight - (UIApplication.shared.statusBarFrame.height + vMargin * 2)

let maxMessageSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 100, height: UIScreen.main.bounds.height/2)

let gifmanager = SwiftyGifManager(memoryLimit:20)
