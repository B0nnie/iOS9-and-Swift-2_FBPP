//
//  PostCell.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/21/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    private var post: Post!
    private(set) var request: Request?
    
    //creating reference for the likes of the current user for a specific post
    private var likeRef: Firebase! {
        return DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        heartImg.addGestureRecognizer(tap)
        heartImg.userInteractionEnabled = true
        
        profileImg.frame.size.width = profileImg.frame.size.height
        
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.frame.size.width = profileImg.frame.size.height
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }
    
    
    func configureCell(post: Post){
        profileImg.frame.size.width = profileImg.frame.size.height
        
        self.post = post
        self.descriptionTxt.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        self.usernameLbl.text  = post.username
        
        //connecting to Firebase to see if the current user has liked this post
        likeRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            
            if let likeNotExist = snapshot.value as? NSNull {
                //if the current user has not liked this specific post
                self.heartImg.image = UIImage(named: "heart-empty")
                
            } else{
                
                self.heartImg.image = UIImage(named: "heart-full")
            }
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer){
        //connecting to Firebase
        likeRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            
            if let likeNotExist = snapshot.value as? NSNull {
                //if the current user has never liked this specific post before, then heart is already empty, make it full
                self.heartImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else{
                //user unlikes this post
                self.heartImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
