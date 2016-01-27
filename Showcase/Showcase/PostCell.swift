//
//  PostCell.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/21/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var likesLbl: UILabel!

    private var post: Post!
    private(set) var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
          profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }

    
    func configureCell(post: Post, img: UIImage?){
        self.post = post
        self.descriptionTxt.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            //if there's an image in the cache, then load it from there
            if img != nil {
                self.showcaseImg.image = img
                
            } else{
               //if there is no image already in the cache, then make a request
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    //request successful
                    if err == nil {
                        
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        
                        //add image to the cache
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                
                
                })
            }
            
        }else {
            
            self.showcaseImg.hidden = true
        }
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
