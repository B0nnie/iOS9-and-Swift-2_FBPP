//
//  PostDetailVC.swift
//  Showcase
//
//  Created by Ebony Nyenya on 3/3/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class PostDetailVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var likesTxtLbl: UILabel!
    @IBOutlet weak var flagBtn: UIView!
    
    private var usersFlaggedPosts: Firebase! {
        return DataService.ds.REF_USER_CURRENT.childByAppendingPath("flaggedPosts").childByAppendingPath(self.post.postKey)
    }
    
    var post: Post!
    var postImage: UIImage!
    var userImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if  DataService.ds.REF_BASE.authData != nil {
            usersFlaggedPosts.observeSingleEventOfType(.Value, withBlock: {snapshot in
                
                if let notFlagged = snapshot.value as? NSNull {
                    self.flagImg.image = UIImage(named: "emptyflag2")
                }else{
                    self.flagImg.image = UIImage(named: "redflag2")
                    self.flagBtn.userInteractionEnabled = false
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if post.likes == 1 {
            likesTxtLbl.text = "Like"
        } else {
            likesTxtLbl.text = "Likes"
        }
        likesLbl.text = "\(post.likes)"
        descriptionLbl.text = post.postDescription
        postImg.image = postImage
        usernameLbl.text = post.username
        
        if post.flagged == true {
            flagBtn.userInteractionEnabled = false
            flagImg.image = UIImage(named: "redflag2")
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        userImgView.image = userImage
        userImgView.clipsToBounds = true
        userImgView.layer.cornerRadius = userImgView.frame.size.width / 2
    }
    
    @IBAction func didFlagPostPressed(sender: UIButton) {
        
        if  DataService.ds.REF_BASE.authData != nil{
            flagImg.image = UIImage(named: "redflag2")
            
            //Step One: present action sheet with 7 options: 1) Sexual content 2) Violent or repulsive content 3)Hateful or abusive content 4) Harmful or dangerous acts 5) Child abuse 6) Infringes my rights 7) Cancel
            reportPost()
        } else{
            //alert view telling user to login before flagging a post
        }
        
        
    }
    
    private func reportPost() {
        let alert = UIAlertController(title: "Report", message: "", preferredStyle: .ActionSheet)
        
        let sContentAction = UIAlertAction(title: "Sexual content", style: .Default, handler: showAlert)
        let violentAction = UIAlertAction(title: "Violent or repulsive content", style: .Default, handler: showAlert)
        let hatefulAction = UIAlertAction(title: "Hateful or abusive content", style: .Default, handler: showAlert)
        let harmfulAction = UIAlertAction(title: "Harmful or dangerous acts", style: .Default, handler: showAlert)
        let abuseAction = UIAlertAction(title: "Child abuse", style: .Default, handler: showAlert)
        let infringeAction = UIAlertAction(title: "Infringes my rights", style: .Default, handler: showAlert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in self.flagImg.image = UIImage(named: "emptyflag2")})
        
        alert.addAction(sContentAction)
        alert.addAction(violentAction)
        alert.addAction(hatefulAction)
        alert.addAction(harmfulAction)
        alert.addAction(abuseAction)
        alert.addAction(infringeAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //Step Two: If an option other than Cancel is chosen, present an alert view that confirms "Report as inappropriate" with options "Yes" and "No"
    private func showAlert(alertAction: UIAlertAction!){
        let alert = UIAlertController(title: "", message: "Report as inappropiate?", preferredStyle: .Alert)
        
        //Step Three: If "yes" is chosen on alert view then do magic and send report to moderator somehow and show an alert view confirming "Reported"
        let reportAction = UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.flagBtn.userInteractionEnabled = false
            self.post.flagged = true
            
            //report stuff here
            DataService.ds.REF_FLAGGED_POSTS.updateChildValues([self.post.postKey: "true"], withCompletionBlock: { (error, firebase) -> Void in
                
                let flaggedPostUsername : [String:AnyObject] = ["username": self.post.username]
                
                DataService.ds.REF_FLAGGED_POSTS.childByAppendingPath(self.post.postKey).setValue(flaggedPostUsername)
                
                self.usersFlaggedPosts.observeSingleEventOfType(.Value, withBlock: {snapshot in
                    
                    if let notFlagged = snapshot.value as? NSNull {
                        //if the current user has never flagged this specific post before, then flag it
                        self.usersFlaggedPosts.setValue(true)
                    }
                })
                
                self.showReportConfirmationAlert()
            })
            
        })
        let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: { _ in self.flagImg.image = UIImage(named: "emptyflag2")})
        
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func showReportConfirmationAlert(){
        let alert = UIAlertController(title: "Confirmed", message: "Post was reported", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func sendMail() {
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Post was flagged")
        picker.setMessageBody("This post was flagged: \(post.postKey)", isHTML: true)
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
}
