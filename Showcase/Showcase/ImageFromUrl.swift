//
//  ImageFromUrl.swift
//
//  Created by Francesco Perrotti-Garcia on 1/19/15.
//  Copyright (c) 2015 Francesco Perrotti-Garcia. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

private var activityIndicatorAssociationKey: UInt8 = 0

extension UIImageView {
    var activityIndicator: UIActivityIndicatorView! {
        get {
            return objc_getAssociatedObject(self, &activityIndicatorAssociationKey) as? UIActivityIndicatorView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &activityIndicatorAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
     func ensureActivityIndicatorIsAnimating() {
//        if (self.activityIndicator == nil) {
//            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
//            self.activityIndicator.hidesWhenStopped = true
//            let size = self.frame.size
//            self.activityIndicator.center = CGPoint(x: size.width/2, y: size.height/2)
//            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                self.addSubview(self.activityIndicator)
//                self.activityIndicator.startAnimating()
//            })
//        }
        
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.activityIndicator)
        
        
        NSLayoutConstraint(item: self.activityIndicator, attribute: .CenterX,
            relatedBy: .Equal, toItem: self,
            attribute: .CenterX, multiplier: 1.0,
            constant: 0.0).active = true
        //
        NSLayoutConstraint(item: self.activityIndicator, attribute: .CenterY,
            relatedBy: .Equal, toItem: self,
            attribute: .CenterY, multiplier: 1.0,
            constant: 0.0).active = true
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.activityIndicator.startAnimating()
        //

    }
    
    convenience init(URL: NSURL, errorImage: UIImage? = nil) {
        self.init()
        self.setImageFromURL(URL)
    }
    
    func setImageFromURL(URL: NSURL, errorImage: UIImage? = nil) {
        self.ensureActivityIndicatorIsAnimating()
        let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(URL) {(data, response, error) in
            if (error == nil) {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.activityIndicator.stopAnimating()
                    self.image = UIImage(data: data!)
                })
            }
            else {
                self.image = errorImage
            }
        }
        downloadTask.resume()
    }
}