//
//  ViewController.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/18/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTxtFld: MaterialTextField!
    @IBOutlet weak var passwordTxtFld: MaterialTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(Constants.KEY_UID) != nil {
            self.segueAfterLoggingIn()
        }
    }
    
    //login with facebook
    @IBAction func fbBtnPressed(sender: UIButton!){
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            
                            //sync up with Firebase
                            let user = ["provider" : authData.provider!, "blah": "test"]
                            DataService.ds.createFirebaseUser(authData.uid, user: user)
                            
                            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: Constants.KEY_UID)
                            self.segueAfterLoggingIn()
                        }
                })
            }
        }
        
    }
    
    //email and password login
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailTxtFld.text where email != "", let pwd = passwordTxtFld.text where pwd != "" {
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                
                if error != nil {
                    // an error occured while attempting login
                    print("an error occured while attempting login: \(error)")
                    
                    if error.code == Constants.STATUS_ACCOUNT_NONEXIST {
                        self.showAccountCreationAlert()
                        
                        //            DataService.ds.REF_BASE.createUser(self.emailTxtFld.text, password: self.passwordTxtFld.text, withValueCompletionBlock: { error, result in
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
                        //should init user here from User class, maybe do something like:
                        //  let user = User(dictionary: [String : String])
                        // user.createFirebaseUser(uid: String, user)
                        
                        
                        
                        
                        //                        let user = ["provider" : authData.provider!, "blah": "emailTest"]
                        //                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        //
                        //                        //self.showWelcomeAlertAndPerformSegue()
                        //
                        //                    })
                        //                }
                        //                
                        //            })
  
                    } else {
                        //there's some other kind of error
                        self.showErrorAlert("Could not log in", msg: "Please check your username or password")
                    }
                    
                } else {
                    // user is logged in, check authData for data
                    print("Logged in with email and password")
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: Constants.KEY_UID)
                    self.segueAfterLoggingIn()
                }
                
            })
            
        } else {
            //textfields were empty
            showErrorAlert("Email and password required", msg: "You must enter an email and a password")
        }
    }
    
    func showAccountCreationAlert(){
        let alert = UIAlertController(title: "Account not found", message: "There is no account linked to your credentials. Press OK to join our community", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            //remove all this later
//                        DataService.ds.REF_BASE.createUser(self.emailTxtFld.text, password: self.passwordTxtFld.text, withValueCompletionBlock: { error, result in
//            
//                            //error
//                            if error != nil {
//                                self.showErrorAlert("Could not create account", msg: "Please try again")
//            
//                            } else {
//                                //successful
//            
//                                NSUserDefaults.standardUserDefaults().setValue(result[Constants.KEY_UID], forKey: Constants.KEY_UID)
//            
//                                DataService.ds.REF_BASE.authUser(self.emailTxtFld.text, password: self.passwordTxtFld.text, withCompletionBlock: { err, authData in
//            
//                                    //sync up with Firebase
//        
//                                    let user = ["provider" : authData.provider!, "blah": "emailTest"]
//                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
//            
//                                    //self.showWelcomeAlertAndPerformSegue()
//            
//                                })
//                            }
//            
//                        })
            
            self.performSegueWithIdentifier("toCreateVCNav", sender: nil)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(signUpAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
//    func showWelcomeAlertAndPerformSegue() {
//
//        let alert = UIAlertController(title: "Account Created", message: "Welcome!", preferredStyle: .Alert)
//        let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
//            
//            self.segueAfterLoggingIn()
//        })
//        
//        alert.addAction(signUpAction)
//        self.presentViewController(alert, animated: true, completion: nil)
//    }
    
    
    func showErrorAlert(title: String, msg: String){
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler : nil))
        
        presentViewController(alert, animated: true, completion: nil)
    
    }
    
    func segueAfterLoggingIn(){
        
        self.performSegueWithIdentifier("loggedIn", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCreateVCNav" {
        
            if let createProfileVCNav = segue.destinationViewController as? UINavigationController {
                let createProfileVC = createProfileVCNav.viewControllers[0] as! CreateProfileVC
                createProfileVC.email = self.emailTxtFld.text
                createProfileVC.password = self.passwordTxtFld.text
            }
        }
        
    }
    
}

