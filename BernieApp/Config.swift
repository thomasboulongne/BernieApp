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

let IMGUR_CLIENT_ID = "46ce83c835caa77"
let IMGUR_CLIENT_SECRET = "6c287269f702b1579ab3faf0fe3875e71d28ddf0"


let TextFieldHeight = 74.0
let ShortcutButtonHeight = 40.0
let takePhotoButtonHeight = 50.0
let optionalButtonHeight = 25.0
let closeButtonHeight = 30.0


let hMargin: CGFloat = 30.0
let vMargin: CGFloat = 10.0

let headerHeight: CGFloat = 100.0

let richcardSize: CGSize = CGSize(width: 220, height: 220)

let richcardMargin: CGFloat = 6.0

let richcardScaleDown: CGFloat = 0.8

let richcardRadius: CGFloat = 10

let detailsPadding: CGFloat = 15

let detailsSubitemHeight: CGFloat = 110

let logoSize: CGFloat = (headerHeight - (UIApplication.shared.statusBarFrame.height + vMargin * 2))

let logoPadding: CGFloat = logoSize / 2.4

let maxMessageSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 100, height: UIScreen.main.bounds.height/2)

let gifmanager = SwiftyGifManager(memoryLimit:20)

let black: UIColor = UIColor(colorLiteralRed: 45/255, green: 45/255, blue: 45/255, alpha: 1.0)
let brownishgrey: UIColor = UIColor(colorLiteralRed: 94/255, green: 94/255, blue: 94/255, alpha: 1.0)
let grey: UIColor = UIColor(colorLiteralRed: 125/255, green: 125/255, blue: 125/255, alpha: 1.0)
let greyish: UIColor = UIColor(colorLiteralRed: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
