//
//  PersistentData.swift
//  Showcase
//
//  Created by Ebony Nyenya on 2/4/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation

class PersistentData {

    //KEYS
    static let KEY_TEMP_TEXT = "text"
    
    
    //METHODS
    
     //retrieve
    static func getStringFromUserDefaultsWithKey(key: String) -> AnyObject? {
        
        if let value = NSUserDefaults.standardUserDefaults().valueForKey(key) as? String {
            return value
        }
            
        else {
            return nil
        }
        
    }
    
     //save
    static func saveValueToUserDefaultsWithKey(key: String, value: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: key)
    }
    
     //delete
    static func resetValueForKeyToNil(key: String) {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: key)
    }
    
    
}