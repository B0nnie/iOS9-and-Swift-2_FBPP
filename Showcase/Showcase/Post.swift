//
//  Post.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/25/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation

class Post {
    
    private(set) var postDescription : String!
    private(set) var imageUrl: String!
    private(set) var likes: Int!
    private(set) var username: String!
    private(set) var postKey: String!
    
    //make a new post when user is new
    init(description: String, imageUrl: String, username: String) {
        
        self.postDescription = description
        self.imageUrl = imageUrl
        self.username = username
    }
    
    //make a new post when user already exists
    init(postKey: String, dictionary: [String:AnyObject]){
       
        self.postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
//        else {
//            self.likes = 0
//        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            
            self.imageUrl = imageUrl
        }
        
        if let desc = dictionary["description"] as? String {
            
            self.postDescription = desc
        }
        
    }
    
}