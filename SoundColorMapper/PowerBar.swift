//
//  PowerBar.swift
//  SoundColorMapper
//
//  Created by Tirodkar, Aditya on 12/14/14.
//  Copyright (c) 2014 Tirodkar, Aditya. All rights reserved.
//

import UIKit

@IBDesignable
class PowerBar: UIView {
    
    var theHeight : CGFloat = 0.0
    
    @IBInspectable var color : UIColor = UIColor.blackColor() {
        didSet {
            layer.backgroundColor = color.CGColor
        }
    }
    
    func animateToHeightPercentage(percentage : NSNumber) {
        UIView.animateWithDuration(0.1, animations: { self.frame = CGRect(
            x: self.frame.origin.x,
            y: (self.theHeight + self.frame.size.height * CGFloat(percentage.floatValue)),
            width: self.frame.size.width,
            height: self.frame.size.height
            )},
            completion: nil
        )
        
        //println((0 + self.frame.size.height * CGFloat(percentage.floatValue)))
    }
    
    override func awakeFromNib() {
        theHeight = self.frame.origin.y
        super.awakeFromNib()
    }
    
}
