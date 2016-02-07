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
    
       
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        makeImgRound()
    }
    
    @IBAction func chooseProfilePic(sender: UIButton) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func doneBtnPressed(sender: UIButton) {
        
        if let username = usernameFld.text where username != "" {
            
            //check to see if user wants to use default profile image
            if profilePicImg.image == UIImage(named:"default") {
                
                let alert = UIAlertController(title: "", message: "Press 'OK' to use the default image or 'Cancel' to go back and choose your own image", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
                    
                    self.signNewUserUp(username)
                })
                
                alert.addAction(cancelAction)
                alert.addAction(signUpAction)
                self.presentViewController(alert, animated: true, completion: nil)
               
            } else{
                self.signNewUserUp(username)
            }
          
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
    
    private func showAlert(title: String, msg: String){
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler : nil))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func showWelcomeAlertAndPerformSegue() {
        
        let alert = UIAlertController(title: "Account Created", message: "Welcome! Press OK if you're awesome", preferredStyle: .Alert)
        let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.performSegueWithIdentifier("toFeedVC", sender: nil)
        })
        
        alert.addAction(signUpAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func signNewUserUp(username: String){
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
            
            let url = (NSURL: "https://post.imageshack.us/upload_api.php")
            
            //turn image into NSData and compress it
            let imgData = UIImageJPEGRepresentation(self.profilePicImg.image!, 0.2)!
            //turn these strings into NSData
            let keyData = "45BHIJOV53cb774724bf91772c598f8f754c3055".dataUsingEncoding(NSUTF8StringEncoding)!
            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
            
            
            Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                //upload image data
                multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                //upload key data
                multipartFormData.appendBodyPart(data: keyData, name: "key")
                //upload json data
                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                
                }) { encodingResult in
                    
                   // self.activityIndicator.startAnimating()
                    
                    switch encodingResult {
                        //successfully uploaded image to ImageShack
                    case .Success(let upload,_,_): upload.responseJSON(completionHandler: { response in
                        //json
                        if let info = response.result.value as? [String:AnyObject]{
                            
                            if let links = info["links"] as? [String:AnyObject]{
                                if let imgLink = links["image_link"] as? String {
                                    //print("IMAGE LINK FROM IMAGESHACK: \(imgLink)")
                                    //uploading image link we got back from ImageShack to Firebase
                                    
                                    //User init
                                    self.user = User(username: username, userImageUrl: imgLink)
                                    
                                    //save username & userImageUrl in nsuserdefaults
                                    PersistentData.saveValueToUserDefaultsWithKey(Constants.KEY_USERNAME, value: self.user.username)
                                    PersistentData.saveValueToUserDefaultsWithKey(Constants.KEY_USERIMAGE, value: self.user.userImageUrl)
                                
                                    //create user in Firebase
                                    self.user.createNewUser(self.email, password: self.password, username: self.user.username, img: self.user.userImageUrl)
                                    
                                    self.showWelcomeAlertAndPerformSegue()
                                }
                            }
                        }
                       
                      //  self.activityIndicator.stopAnimating()
                       
                    })
                        //unsuccessful in uploading image to ImageShack
                    case .Failure(let error):
                        print(error)
                        
                       // self.activityIndicator.stopAnimating()
                        self.showAlert("", msg: "There was an error saving your image. Please try again.")
                    }
            }
  
        })
        
    }
    
    private func makeImgRound() {
        profilePicImg.clipsToBounds = true
        profilePicImg.layer.masksToBounds = true
        profilePicImg.layer.cornerRadius = profilePicImg.frame.size.height/2
    }
    
}
