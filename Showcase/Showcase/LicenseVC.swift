//
//  LicenseVC.swift
//  Showcase
//
//  Created by Ebony Nyenya on 3/1/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit

class LicenseVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    @IBAction func doneBtnPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true
            , completion: nil)
    }

}
