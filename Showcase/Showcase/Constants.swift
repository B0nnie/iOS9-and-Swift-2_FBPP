//
//  Constants.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/19/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    static let SHADOW_COLOR = UIColor(red: 0, green: 0.376, blue: 0.392, alpha: 1.0)
    static let LINEAR_BAR: LinearProgressBar = LinearProgressBar()
    static var NAVIGATION_BAR_HEIGHT : CGFloat = 0.0
    
    //Keys
    static let KEY_USERNAME = "username"
    static let KEY_USERIMAGE = "userImage"
  
    //Segues
    //static let SEGUE_LOGGED_IN = "loggedIn"
    
    //Status Codes
    static let STATUS_ACCOUNT_NONEXIST = -8
    static let STATUS_INVALID_EMAIL = -5
    static let STATUS_INVALID_PASSWORD = -6
    static let STATUS_NETWORK_ERROR = -15
    
    //FUNCTIONS
    static func FUNC_SHOWALERT(title: String, msg: String, vc: UIViewController){
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler : nil))
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
}

