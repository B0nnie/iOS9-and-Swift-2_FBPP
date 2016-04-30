//
//  TextPickerVC.swift
//  Showcase
//
//  Created by Ebony Nyenya on 4/29/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit

protocol DidEnterTextDelegate : class {
    func didEnterText(enteredText: String)
}


class TextPickerVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var TxtViewDescription: UITextView!
    
    let placeHolderTxt = "Tell us about your project! "
    var oldText: String?
    var textColor: UIColor!
    var placeholderColor = UIColor.lightGrayColor()
    
    weak var delegate: DidEnterTextDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textColor = TxtViewDescription.textColor
        
        TxtViewDescription.delegate = self
        TxtViewDescription.becomeFirstResponder()
        
        if let text = oldText {
            TxtViewDescription.text = text
            
        } else {
            TxtViewDescription.textColor = placeholderColor
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        TxtViewDescription.clipsToBounds = true
        TxtViewDescription.layer.cornerRadius = TxtViewDescription.frame.size.width/20
    }
    
    @IBAction func dismissVC(sender: UIButton) {
    
        TxtViewDescription.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView.text == placeHolderTxt {
            textView.text = ""
            textView.textColor = textColor
        }
        
        if text == "\n" {
            textView.resignFirstResponder()
            
            delegate?.didEnterText(textView.text)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return false
        }
        
        return true
    }
    
}
