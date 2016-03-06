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

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTxtFld: MaterialTextField!
    @IBOutlet weak var passwordTxtFld: MaterialTextField!
    @IBOutlet weak var materialViewBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var facebookBtn: MaterialButton!
    @IBOutlet weak var loginBtn: MaterialButton!
    @IBOutlet weak var constraintMaterialViewTopLayout: NSLayoutConstraint!
    
    private var showKeyboard = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxtFld.delegate = self
        passwordTxtFld.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        shiftUIWithKeyboard()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        Constants.NAVIGATION_BAR_HEIGHT =  self.navigationController!.navigationBar.frame.size.height
        self.view.addSubview(Constants.LINEAR_BAR)
    }
    
    //login with facebook
    @IBAction func fbBtnPressed(sender: UIButton!){
        
        startActivityIndicator()
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                self.stopActivityIndicator()
                
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                self.stopActivityIndicator()
                
                print("Facebook login was cancelled.")
            } else {
                //successful
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                //connect with Firebase
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            self.stopActivityIndicator()
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
                                    }
                                    
                                }
                                facebookLogin.logOut()
                            }
                            
                            self.stopActivityIndicator()
                            self.segueToFeedVCAfterLoggingIn()
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
            
            startActivityIndicator()
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                
                if error != nil {
                    // an error occured while attempting login
                    print("an error occured while attempting login: \(error)")
                    
                    self.stopActivityIndicator()
                    
                    switch error.code {
                    case Constants.STATUS_ACCOUNT_NONEXIST: self.showAccountCreationAlert()
                    case Constants.STATUS_INVALID_EMAIL: self.showErrorAlert("Could not log in", msg: "Please re-enter your email address")
                    case Constants.STATUS_INVALID_PASSWORD: self.showErrorAlert("Could not log in", msg: "Please re-enter your password")
                    case Constants.STATUS_NETWORK_ERROR: self.showErrorAlert("Error", msg: "No online connectivity. Please turn on Wi-Fi or cellular data.")
                    default: self.showErrorAlert("Could not log in", msg: "Please try again")
                        
                    }
                    
                } else {
                    // user is already authorized
                    //print("Logged in with email and password")
                    
                    self.stopActivityIndicator()
                    
                    DataService.ds.checkIfBannedUser( { banned in
                        if banned == true {
                            self.showErrorAlert("Error", msg: "Your account has been blocked due to violating the End User License Agreement. Unable to log in.")
                            return
                        } else{
                            self.segueToFeedVCAfterLoggingIn()
                        }
                        
                    })
                    
                }
                
            })
            
        } else {
            //textfields were empty
            showErrorAlert("Email and password required", msg: "Please enter an email and a password")
        }
    }
    
    private func showAccountCreationAlert(){
        let alert = UIAlertController(title: "Account not found", message: "There is no account linked to your credentials. Tap 'OK' to join our community", preferredStyle: .Alert)
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
    
    private func segueToFeedVCAfterLoggingIn(){
        navigationController?.popToRootViewControllerAnimated(true)
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
    
    private func shiftUIWithKeyboard() {
        
        var keyboardHeight: CGFloat = 0
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            if let kbSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                if self.showKeyboard{
                    // move constraint
                    keyboardHeight = kbSize.height
                    
                    self.constraintMaterialViewTopLayout.constant -= keyboardHeight / 1.3
                    
                    self.materialViewBottomLayout.constant += keyboardHeight / 1.3
                    
                    self.view.layoutIfNeeded()
                    
                    self.showKeyboard = false
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            // move constraint back
            if let kbSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                keyboardHeight = kbSize.height
                
                self.materialViewBottomLayout.constant = 0
                self.constraintMaterialViewTopLayout.constant = 0
                
                self.view.layoutIfNeeded()
                self.showKeyboard = true
            }
        }
        
    }
    
    private func startActivityIndicator(){
        Constants.LINEAR_BAR.startAnimation()
        facebookBtn.userInteractionEnabled = false
        facebookBtn.alpha = 0.7
        loginBtn.userInteractionEnabled = false
        loginBtn.alpha = 0.7
    }
    
    private func stopActivityIndicator(){
        Constants.LINEAR_BAR.stopAnimation()
        self.facebookBtn.alpha = 1.0
        self.facebookBtn.userInteractionEnabled = true
        loginBtn.userInteractionEnabled = true
        loginBtn.alpha = 1.0
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

