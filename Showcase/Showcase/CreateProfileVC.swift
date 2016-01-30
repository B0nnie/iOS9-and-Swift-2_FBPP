//
//  CreateProfileVC.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/28/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class CreateProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameFld: MaterialTextField!
    @IBOutlet weak var profilePicImg: UIImageView!
    private var imagePicker: UIImagePickerController!
    private var user: User!
    var email: String!
    var password: String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        print("Email: \(email) \n Password: \(password)")
        
    }
    
    
    @IBAction func chooseProfilePic(sender: UIButton) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func doneBtnPressed(sender: UIButton) {
        
        if let username = usernameFld.text where username != "" {
            
            DataService.ds.REF_USERS.observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                //confirm username isn't taken and show alert if it is taken
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    
                    for snap in snapshots {
                        
                        if let value = snap.value as? [String: AnyObject]{
                            if let firebaseUsers = value["username"] as? String {
                                //print("USERNAME VALUES: \(firebaseUsers)")
                                
                                
                                if(username.caseInsensitiveCompare(firebaseUsers) == NSComparisonResult.OrderedSame){
                                    self.showAlert("This username is already being used", msg: "Please come up with another username, you creative genius!")
                                    
                                    self.usernameFld.text = ""
                                }
                            }
                        }
                    }
                    
                }
                
                //create user in Firebase
                self.user = User(username: username)
                self.user.createNewUser(self.email, password: self.password, username: username)
                
            })
            
        } else {
            
            showAlert("", msg: "Please enter a username")
        }
    }
    
    @IBAction func cancelBtnPressed(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profilePicImg.image = image
    }
    
    func showAlert(title: String, msg: String){
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler : nil))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func showWelcomeAlertAndPerformSegue() {
        
        let alert = UIAlertController(title: "Account Created", message: "Welcome!", preferredStyle: .Alert)
        let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.performSegueWithIdentifier("toFeedVC", sender: nil)
        })
        
        alert.addAction(signUpAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
}
