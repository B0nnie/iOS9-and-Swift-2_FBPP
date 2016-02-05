//
//  FeedVC.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/21/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postFld: MaterialTextField!
    @IBOutlet weak var selectedAppImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var posts = [Post]()
    private var imagePicker: UIImagePickerController!
    private var imageCache = NSCache()
    private var deletePostIndexPath: NSIndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = PersistentData.tempText {
            postFld.text = text
            
            PersistentData.tempText = nil
            
        }
        if let img = PersistentData.tempImg {
            
            selectedAppImg.image = img
            
            PersistentData.tempImg = nil
        }
        
        tableView.delegate  = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        tableView.estimatedRowHeight = 372
        
        //get all the posts from Firebase, convert each into a Post object, and add the Posts to the posts array
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: {snapshot in
            //print(snapshot.value)
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    //print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? [String:AnyObject] {
                        
                        let key = snap.key
                        //Post init
                        let post = Post(postKey: key, dictionary: postDict)
                        //print("POST KEY IS: \(post.postKey)")
                        
                        self.posts.insert(post, atIndex: 0)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
   
    
    //MARK: TableView Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        //print("MY POST IN CELLFORROW: \(post.postDescription) and my imageUrl \(post.imageUrl)")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostCell
        
        cell.showcaseImg.clipsToBounds = true
        
        cell.profileImg.image = nil
        cell.showcaseImg.image = nil
        
        cell.tag = indexPath.row
        
        
        cell.configureCell(post)
        
        var postImg: UIImage?
        var userImg: UIImage?
        
        if let postImgUrl = post.imageUrl {
            
            //get image from cache
            postImg = imageCache.objectForKey(postImgUrl) as? UIImage
            
        }
        
        if let userImgUrl = post.userImageUrl{
            
            //get image from cache
            userImg = imageCache.objectForKey(userImgUrl) as? UIImage
        }
        
        
        if post.userImageUrl != nil {
            
            //if there's an image in the cache, then load it from there
            if userImg != nil {
                
                cell.profileImg.image = userImg
                
            } else {
                
                //TODO: Refactor
                //if there is no image already in the cache, then make a request to get it from ImageShack
                
                //activity indicator while image loads
                cell.profileImg.ensureActivityIndicatorIsAnimating()
                
                Alamofire.request(.GET, post.userImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    //activity indicator when image finishes loading
                    cell.profileImg.activityIndicator.stopAnimating()
                    //                        request successful
                    if err == nil {
                        
                        
                        if cell.tag == indexPath.row {
                            let img = UIImage(data: data!)!
                            cell.profileImg.image = img
                            self.imageCache.setObject(img, forKey: post.userImageUrl!)
                        }
                        
                        
                        
                        
                        //add image to the cache for later use
                        
                    }
                    
                    
                })
            }
        }
        
        if post.imageUrl != nil {
            
            //if there's an image in the cache, then load it from there
            if postImg != nil {
                
                
                cell.showcaseImg.image = postImg
                
            } else {
                
                
                //TODO: Refactor
                //if there is no image already in the cache, then make a request to get it from ImageShack
                
                
                cell.showcaseImg.ensureActivityIndicatorIsAnimating()
                Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    
                    
                    cell.showcaseImg.activityIndicator.stopAnimating()
                    
                    
                    //request successful
                    if err == nil {
                        
                        
                        if cell.tag == indexPath.row {
                            let img = UIImage(data: data!)!
                            cell.showcaseImg.image = img
                            
                            
                            //add image to the cache for later use
                            self.imageCache.setObject(img, forKey: post.imageUrl!)
                            
                        }
                    }
                    
                    
                })
            }
            
        }
        
        return cell
        
        
    }
    
    //to keep profile images from messing up after scrolling
    //     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //        let post = posts[indexPath.row]
    //
    //        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
    //            cell.request?.cancel()
    //
    //            cell.configureCell(post)
    //
    //        }
    //
    //    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            if let username = PersistentData.getStringFromUserDefaultsWithKey(Constants.KEY_USERNAME) as? String
            {
                let post = posts[indexPath.row]
                
                if  post.username == username {
                    
                    deletePostIndexPath = indexPath
                    let postToDelete = posts[indexPath.row]
                    confirmDelete(postToDelete)
                }
            }
            
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if let username = PersistentData.getStringFromUserDefaultsWithKey(Constants.KEY_USERNAME) as? String {
            let post = posts[indexPath.row]
            
            if  post.username == username {
                return true
            }
            
        }
        return false
    }
    
    //configure row height depending on if user uploaded image or not
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //
    //        let post = posts[indexPath.row]
    //
    //        if post.imageUrl == nil {
    //            return 150
    //        } else {
    //            return tableView.estimatedRowHeight
    //        }
    //    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        selectedAppImg.image = image
    }
    
    
    @IBAction func selectAppImage(sender: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: MaterialButton) {
        
        if let txt = postFld.text where txt != "", let img = selectedAppImg.image where img != UIImage(named:"camera")  {
            
            //first check if user is authorized in Firebase, and if she is then save her uid, username, and userImgUrl in userDefaults; otherwise show alert prompting user to create account and segue to LoginVC
            
            if PersistentData.getStringFromUserDefaultsWithKey(Constants.KEY_UID) == nil{
                showLoginAlert()
                
            } else {
                
                //MARK: Uploading image data to ImageShack
                let url = (NSURL: "https://post.imageshack.us/upload_api.php")
                
                //turn image into NSData and compress it
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
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
                        
                        self.activityIndicator.startAnimating()
                        
                        switch encodingResult {
                            //successfully uploaded image to ImageShack
                        case .Success(let upload,_,_): upload.responseJSON(completionHandler: { response in
                            //json
                            if let info = response.result.value as? [String:AnyObject]{
                                
                                if let links = info["links"] as? [String:AnyObject]{
                                    if let imgLink = links["image_link"] as? String {
                                        //print("IMAGE LINK FROM IMAGESHACK: \(imgLink)")
                                        //uploading image link we got back from ImageShack to Firebase
                                        self.postToFirebase(imgLink)
                                    }
                                }
                            }
                            //reset textfield and camera image
                            self.postFld.text = ""
                            self.selectedAppImg.image = UIImage(named:"camera")
                            
                            self.activityIndicator.stopAnimating()
                            
                            //alerting user post was created successfully
                            self.showAlert("", msg: "Your post was created! Thanks for sharing.")
                            
                            
                        })
                            //unsuccessful in uploading image to ImageShack
                        case .Failure(let error):
                            print(error)
                            
                            self.activityIndicator.stopAnimating()
                            self.showAlert("", msg: "There was an error creating your post. Try again.")
                        }
                }
                
            }
            
        }else {
            //error alert message saying they need to enter a description and choose an app image
            showAlert("", msg: "Please enter a description for your app and choose an image")
            
        }
        
    }
    
    private func showAlert(title: String, msg: String){
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler : nil))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func showLoginAlert(){
        
        let alert = UIAlertController(title: "Login Required", message: "Please login before posting about your app", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let signUpAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
            
                if let text = self.postFld.text {
                    PersistentData.tempText = text
                }
                
                if let img = self.selectedAppImg.image {
                    PersistentData.tempImg = img
                }
            
            self.performSegueWithIdentifier("toLoginVC", sender: nil)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(signUpAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func confirmDelete(post:Post) {
        let alert = UIAlertController(title: "Delete Post", message: "Are you sure you want to permanently delete your post?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeletePost)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeletePost)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func handleDeletePost(alertAction: UIAlertAction!){
        
        if let indexPath = deletePostIndexPath {
            tableView.beginUpdates()
            let post = posts[indexPath.row]
            
            //Delete post from Firebase:
            
            //delete from posts ref
            post.postRef.removeValue()
            //delete from users/uid/posts ref
            DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(post.postKey).removeValue()
            //delete from users/uid/likes ref
            DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey).removeValue()
            
            posts.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            deletePostIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    private func cancelDeletePost(alertAction: UIAlertAction!) {
        deletePostIndexPath = nil
    }
    
    
    private func postToFirebase(imgUrl: String){
        
        if let userImg = PersistentData.getStringFromUserDefaultsWithKey(Constants.KEY_USERIMAGE) as? String, let name = PersistentData.getStringFromUserDefaultsWithKey(Constants.KEY_USERNAME) as? String {
            
            //making a new post
            //matches format of test data in Firebase
            let post: [String:AnyObject] = [
                "description": postFld.text!,
                "likes": 0,
                "imageUrl": imgUrl,
                "userImgUrl": userImg,
                "username": name]
            
            //connect with Firebase
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
            
            DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").updateChildValues([firebasePost.key: "true"])
            
            tableView.reloadData()
            
        }
    }
    
}
   