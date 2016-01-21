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
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
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
                            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
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
                    
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        self.showAccountCreationAlert()
  
                    } else {
                        //there's some other kind of error
                        self.showAlert("Could not log in", msg: "Please check your username or password")
                    }
                    
                } else {
                    // user is logged in, check authData for data
                    print("Logged in with email and password")
                    self.segueAfterLoggingIn()
                }
                
            })
            
        } else {
            //textfields were empty
            showAlert("Email and password required", msg: "You must enter an email and a password")
        }
    }
    
    func showAccountCreationAlert(){
        let alert = UIAlertController(title: "Account not found", message: "There is no account linked to your credentials. Press OK to create an account", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
           
            DataService.ds.REF_BASE.createUser(self.emailTxtFld.text, password: self.passwordTxtFld.text, withValueCompletionBlock: { error, result in
                
                //error
                if error != nil {
                    self.showAlert("Could not create account", msg: "Please try again")
                    
                } else {
                    //successful
                    
                    NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                    
                    DataService.ds.REF_BASE.authUser(self.emailTxtFld.text, password: self.passwordTxtFld.text, withCompletionBlock: { _ in
                        
                        self.showWelcomeAlertAndPerformSegue()
                    })
                }
                
            })
        })
        
        alert.addAction(cancelAction)
        alert.addAction(signUpAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    func showWelcomeAlertAndPerformSegue() {

        let alert = UIAlertController(title: "Account Created", message: "Welcome!", preferredStyle: .Alert)
        let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.segueAfterLoggingIn()
        })
        
        alert.addAction(signUpAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func showAlert(title: String, msg: String){
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler : nil))
        
        presentViewController(alert, animated: true, completion: nil)
    
    }
    
    func segueAfterLoggingIn(){
        
        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
    }
    
}

