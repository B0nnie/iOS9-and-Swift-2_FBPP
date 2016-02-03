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
    
    @IBOutlet weak var materialViewBottomLayout: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shiftUIWithKeyboard()
        
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
                //successful
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                //connect with Firebase
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            //successful
                            print("Logged in! \(authData)")
                            
                            let fbloginresult : FBSDKLoginManagerLoginResult = facebookResult
                            if(fbloginresult.grantedPermissions.contains("email"))
                            {
                                self.getFBUserData { userDict in
                                    
                                    //create facebook user in Firebase
                                    if let username = userDict["name"] as? String, let pictureDict = userDict["picture"] as? [String:AnyObject], let dataDict = pictureDict["data"] as? [String:AnyObject], let fbImgUrl = dataDict["url"] as? String  {
                                        let user = User(username: username, userImageUrl: fbImgUrl)
                                        
                                        let facebookUser = ["provider" : authData.provider!,
                                            "username": user.username, "userImgUrl": user.userImageUrl]
                                        
                                        DataService.ds.createFirebaseUser(authData.uid, user: facebookUser)
                                        
                                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: Constants.KEY_UID)
                                        NSUserDefaults.standardUserDefaults().setValue(user.username, forKey: "username")
                                        NSUserDefaults.standardUserDefaults().setValue(user.userImageUrl, forKey: "userImage")
                                    }
                                    
                                }
                                facebookLogin.logOut()
                            }
                            self.segueAfterLoggingIn()
                        }
                })
            }
        }
        
    }
    
    //get username and profile pic from facebook
    private func getFBUserData(completionHandler: [String:AnyObject] -> ()) {
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, picture.type(large)"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if error == nil {
                    //successful
                    if let userDict = result as? [String:AnyObject] {
                        completionHandler(userDict)
                    }
                    
                }
            })
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
                        
                    } else {
                        //there's some other kind of error
                        self.showErrorAlert("Could not log in", msg: "Please check your username or password")
                    }
                    
                } else {
                    // user is logged in, check authData for data
                    //print("Logged in with email and password")
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: Constants.KEY_UID)
                    
                    if NSUserDefaults.standardUserDefaults().valueForKey("username") == nil {
                        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
                            if snapshot.value != nil {
                                
                                if let username = snapshot.value.objectForKey("username"), let imgUrl = snapshot.value.objectForKey("userImgUrl"){
                                    NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
                                    NSUserDefaults.standardUserDefaults().setValue(imgUrl, forKey: "userImage")
                                }
                            }
                            
                        })
                        
                    }
                    
                    self.segueAfterLoggingIn()
                }
                
            })
            
        } else {
            //textfields were empty
            showErrorAlert("Email and password required", msg: "You must enter an email and a password")
        }
    }
    
    private func showAccountCreationAlert(){
        let alert = UIAlertController(title: "Account not found", message: "There is no account linked to your credentials. Press OK to join our community", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            
            self.performSegueWithIdentifier("toCreateVCNav", sender: nil)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(signUpAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    private func showErrorAlert(title: String, msg: String){
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler : nil))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func segueAfterLoggingIn(){
        
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
    
    func shiftUIWithKeyboard() {
        
        var keyboardHeight: CGFloat = 0
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            if let kbSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                // move constraint
                keyboardHeight = kbSize.height
                self.materialViewBottomLayout.constant += keyboardHeight
                
                self.view.layoutIfNeeded()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            // move constraint back
            if let kbSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                keyboardHeight = kbSize.height
                self.materialViewBottomLayout.constant -= keyboardHeight
                
                
                self.view.layoutIfNeeded()
            }
        }
       
    }
    
}

