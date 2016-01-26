//
//  FeedVC.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/21/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate  = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 372
        
        //get the posts from Firebase, create a Post object, and add the Post to the posts array
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: {snapshot in
            //print(snapshot.value)
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    //print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? [String:AnyObject] {
                        
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
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
        print(post.postDescription)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.request?.cancel()
            var img: UIImage?
            
            if let url = post.imageUrl {
               img = FeedVC.imageCache.objectForKey(url) as? UIImage
                
            }
            
            
            cell.configureCell(post, img: img)
            
            return cell
            
        } else {
            
           return PostCell()
        }
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    
    
}
