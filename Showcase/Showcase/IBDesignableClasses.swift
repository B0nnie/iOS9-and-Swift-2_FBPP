//
//  ClassExtensions.swift
//  Showcase
//
//  Created by Ebony Nyenya on 2/7/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable  class customButton: UIButton {
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            
            self.clipsToBounds = true
            self.layer.borderColor = borderColor?.CGColor
            
        }
    }
   
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
            
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
            
        }
    }
}



@IBDesignable  class customImageView: UIImageView {
    
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            
            self.clipsToBounds = true
            self.layer.borderColor = borderColor?.CGColor
            
        }
    }
   
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
            
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
            
        }
    }
    
}