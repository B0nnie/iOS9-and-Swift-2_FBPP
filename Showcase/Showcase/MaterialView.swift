//
//  MaterialView.swift
//  Showcase
//
//  Created by Ebony Nyenya on 1/19/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit

class MaterialView: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = Constants.SHADOW_COLOR.CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
    }

}
