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
        layer.borderColor = UIColor(red: Constants.SHADOW_COLOR, green: Constants.SHADOW_COLOR, blue: Constants.SHADOW_COLOR, alpha: 0.1).CGColor
        layer.borderWidth = 1.0
    
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
