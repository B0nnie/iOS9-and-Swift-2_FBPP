//
//  DataService.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/21/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation
import Firebase
import Cloudinary

class DataService: NSObject, CLUploaderDelegate {
    
    static let ds = DataService()
    static let URL_BASE = "https://showcase-e-n.firebaseio.com"
    let cloudinary_url = "cloudinary://583966332844476:juShbxmwhdBGjjPxugSwfs0U5fk@ddo2zlkvq"
    
    private (set) var REF_BASE = Firebase(url: "\(URL_BASE)")
    private (set) var REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private (set) var REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private (set) var REF_FLAGGED_POSTS = Firebase(url: "\(URL_BASE)/flaggedPosts")
    private (set) var REF_BANNED_USERS = Firebase(url: "\(URL_BASE)/bannedUsers")
    var REF_USER_CURRENT :Firebase {
        let uid = DataService.ds.REF_BASE.authData.uid
        let user = Firebase(url: "\(REF_USERS)").childByAppendingPath(uid)
        
        return user
    }
    
    override init(){
        super.init()
    }
    
    func createFirebaseUser(uid: String, user: [String:AnyObject]) {
        REF_USERS.childByAppendingPath(uid).updateChildValues(user)
        
    }
    
    func getUsernameAndImgUrl(){
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("username").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let name = snapshot.value as? String {
                GlobalData.username = name
            }
            
        })
        
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("userImgUrl").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let img = snapshot.value as? String {
                GlobalData.userImg = img
            }
            
        })
        
    }
    
    func uploadImage(image: UIImage, onCompletion: (status: Bool, url: String?) -> Void) {
        
        let cloudinaryHandler = CLCloudinary(url:cloudinary_url)
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        let uploader:CLUploader = CLUploader(cloudinaryHandler, delegate: self)
        uploader.upload(imgData, options: nil,
            withCompletion: { (dataDictionary: [NSObject: AnyObject]?, errorResult:String?, code:Int, context: AnyObject!) -> Void in
                if let error = errorResult {
                    onCompletion(status: false, url: nil)
                    print("Error: \(error)")
                    
                } else{
                    if let data = dataDictionary {
                        let cloudImgUrlStr = data["url"] as! String
                        
                        onCompletion(status: true, url: cloudImgUrlStr)
                    }
                    
                    onCompletion(status: false, url: nil)
                    
                    
                }
                
                //                self.uploadResponse = Mapper<ImageUploadResponse>().map(dataDictionary)
                //                if code < 400 { onCompletion(status: true, url: self.uploadResponse?.imageURL)}
                //                else {onCompletion(status: false, url: nil)}
            },
            andProgress: { (bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, context:AnyObject!) -> Void in
                print("Upload progress: \((totalBytesWritten * 100)/totalBytesExpectedToWrite) %");
            }
        )
    }
    
    
    func deleteImage(publicId: String){
        let cloudinaryHandler = CLCloudinary(url:cloudinary_url)
        let uploader:CLUploader = CLUploader(cloudinaryHandler, delegate: self)
        
        uploader.destroy(publicId, options: nil)
    }
    
    func checkIfBannedUser(completion: (Bool) -> Void) {
        
        DataService.ds.REF_BANNED_USERS.observeSingleEventOfType(.Value, withBlock: {snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                var isBanned = false
                for snap in snapshots {
                    
                    if let key = snap.key {
                    
                        let uid = DataService.ds.REF_BASE.authData.uid
                        
                        if key == String(uid){
                            DataService.ds.REF_BASE.unauth()
                            isBanned = true
                        }
                        
                    }
                    
                }
                
                if isBanned == true {
                    completion(true)
                }else {
                    completion(false)
                }
                
            }
        })
        
    }
    
}