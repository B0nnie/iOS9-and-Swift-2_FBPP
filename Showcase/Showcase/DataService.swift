//
//  DataService.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/21/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let ds = DataService()
    
    static let URL_BASE = "https://showcase-e-n.firebaseio.com"
    
    private (set) var REF_BASE = Firebase(url: "\(URL_BASE)")
    private (set) var REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private (set) var REF_USERS = Firebase(url: "\(URL_BASE)/users")
    
    func createFirebaseUser(uid: String, user: [String:String]) {
        REF_USERS.childByAppendingPath(uid).updateChildValues(user)
        
    }
    
    
}