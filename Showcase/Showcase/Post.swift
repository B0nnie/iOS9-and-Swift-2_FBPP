//
//  Post.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/25/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private(set) var postDescription : String!
    private(set) var imageUrl: String!
    private(set) var likes: Int!
    private(set) var username: String!
    private(set) var postKey: String!
    private(set) var postRef: Firebase!
    private(set) var userImageUrl: String!


//    init(description: String, imageUrl: String, username: String) {
//        
//        self.postDescription = description
//        self.imageUrl = imageUrl
//        self.username = username
//    }
    
    
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
        
        if let name = dictionary["username"] as? String {
            
            self.username = name
        }
        
        if let userImg = dictionary["userImgUrl"] as? String {
            
            self.userImageUrl = userImg
        }
    
        self.postRef = DataService.ds.REF_POSTS.childByAppendingPath(self.postKey)
        
    }
    
    func adjustLikes(addLike: Bool){
        if addLike {
            self.likes = likes + 1
        }else {
            self.likes = likes - 1
        }
        self.postRef.childByAppendingPath("likes").setValue(self.likes)
    }
    
}