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
    
    
    //make a new user
    init(username: String, provider: FAuthData!){
        self.provider = provider
        
    }
    


    
   // DataService.ds.REF_BASE.createUser(self.emailTxtFld.text, password: self.passwordTxtFld.text, withValueCompletionBlock: { error, result in
    //
    //                //error
    //                if error != nil {
    //                    self.showErrorAlert("Could not create account", msg: "Please try again")
    //
    //                } else {
    //                    //successful
    //
    //                    NSUserDefaults.standardUserDefaults().setValue(result[Constants.KEY_UID], forKey: Constants.KEY_UID)
    //
    //                    DataService.ds.REF_BASE.authUser(self.emailTxtFld.text, password: self.passwordTxtFld.text, withCompletionBlock: { err, authData in
    //
    //                        //sync up with Firebase
    //
    //should init user here from User class
    //                        let user = ["provider" : authData.provider!, "blah": "emailTest"]
    //                        DataService.ds.createFirebaseUser(authData.uid, user: user)
    //
    //                        //self.showWelcomeAlertAndPerformSegue()
    //
    //                    })
    //                }
    //
    //            })
    

    
    func createFirebaseUser(uid: String, user: [String:String]) {
        
        DataService.ds.REF_USERS.childByAppendingPath(uid).updateChildValues(user)
    
    }
    
    
}
