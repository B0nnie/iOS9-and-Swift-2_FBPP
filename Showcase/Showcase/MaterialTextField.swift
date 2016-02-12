//
//  MaterialTextField.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/19/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {
    
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.masksToBounds = false
        layer.shadowRadius = 2.0
        layer.shadowColor = Constants.SHADOW_COLOR.CGColor
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        layer.shadowOpacity = 1.0
       
    }
    
    //To indent placeholder text
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    
    }
    
    //To indent text that user types into textfield
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
         return CGRectInset(bounds, 10, 0)
    }
    
}
