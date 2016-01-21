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
    
    private (set) var REF_BASE = Firebase(url: "https://showcase-e-n.firebaseio.com")
    
}