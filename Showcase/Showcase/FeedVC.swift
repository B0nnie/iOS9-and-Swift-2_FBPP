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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                        
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        //print("MY POST IN CELLFORROW: \(post.postDescription) and my imageUrl \(post.imageUrl)")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostCell
        
        cell.showcaseImg.clipsToBounds = true
        
        // size of the screen - 40 (the tableView is 40 smaller than the screen view (check out storyboard (view is 600 and table view is 560))
        cell.showcaseImg.frame.size.width = UIScreen.mainScreen().bounds.width - (UIScreen.mainScreen().bounds.width - self.tableView.bounds.size.width)
        
        
        cell.profileImg.image = nil
        cell.showcaseImg.image = nil
        
        cell.tag = indexPath.row
        
        
        cell.configureCell(post)
        
        var postImg: UIImage?
        var userImg: UIImage?
        
        if let postImgUrl = post.imageUrl {
            
            //get image from cache
            postImg = DataService.imageCache.objectForKey(postImgUrl) as? UIImage
            
        }
        
        if let userImgUrl = post.userImageUrl{
            
            //get image from cache
            userImg = DataService.imageCache.objectForKey(userImgUrl) as? UIImage
        }
        
        
        if post.userImageUrl != nil {
            
            //if there's an image in the cache, then load it from there
            if userImg != nil {
                
                cell.profileImg.image = userImg
                
            } else {
                
                //TODO: Refactor
                //if there is no image already in the cache, then make a request to get it from ImageShack
                //
                cell.profileImg.ensureActivityIndicatorIsAnimating()
                
                Alamofire.request(.GET, post.userImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    cell.profileImg.activityIndicator.stopAnimating()
                    //                        request successful
                    if err == nil {
                        
                        
                        if cell.tag == indexPath.row {
                            let img = UIImage(data: data!)!
                            cell.profileImg.image = img
                            DataService.imageCache.setObject(img, forKey: post.userImageUrl!)
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
                            DataService.imageCache.setObject(img, forKey: post.imageUrl!)
                            
                        }
                    }
                    
                    
                })
            }
            
        }
        
        return cell
        
        
    }
    
    //to keep profile images from messing up after scrolling
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.request?.cancel()
            
            cell.configureCell(post)
         
        }
        
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
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        selectedAppImg.image = image
    }
    
    
    @IBAction func selectAppImage(sender: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: MaterialButton) {
        
        if let txt = postFld.text where txt != "", let img = selectedAppImg.image where img != UIImage(named:"camera")  {
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
    
    private func postToFirebase(imgUrl: String){
        
        let userImg = NSUserDefaults.standardUserDefaults().valueForKey("userImage") as! String
        let name = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        
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
