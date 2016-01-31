//
//  User.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/28/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    private(set) var username : String!
    private(set) var userImageUrl: String!
    private(set) var likes: Int!
    private(set) var userUid: String!
    private(set) var provider: FAuthData!
    private(set) var userRef: Firebase!
    private(set) var userPost: Post!
    
    
    //make a new user object
    init(username: String, userImageUrl: String) {
        self.username = username
        self.userImageUrl = userImageUrl
        
    }
   
    func createNewUser(email: String, password: String, username: String, img: String){
        
         DataService.ds.REF_BASE.createUser(email, password: password, withValueCompletionBlock: { error, result in
        
                        //error
                        if error != nil {
                            //self.showErrorAlert("Could not create account", msg: "Please try again")
        
                        } else {
                            //successful
                            
                            NSUserDefaults.standardUserDefaults().setValue(result[Constants.KEY_UID], forKey: Constants.KEY_UID)
        
                            DataService.ds.REF_BASE.authUser(email, password: password, withCompletionBlock: { err, authData in
                                
                                //connect with Firebase
                                let user : [String: AnyObject] = ["provider" : authData.provider!, "username": username, "userImgUrl": img]
                                DataService.ds.createFirebaseUser(authData.uid, user: user)
        
                                //self.showWelcomeAlertAndPerformSegue()
        
                            })
                        }
        
                    })
        
    }
    

}
