//
//  PowerBarLevelCalculator.swift
//  SoundColorMapper
//
//  Created by Tirodkar, Aditya on 12/15/14.
//  Copyright (c) 2014 Tirodkar, Aditya. All rights reserved.
//

import UIKit

class PowerBarLevelCalculator: NSObject {
    var maxLevel : NSNumber!
    var minLevel : NSNumber!
    var numberOfBars : NSNumber!
    
    init(maxLevel : NSNumber, minLevel : NSNumber, numberOfBars : NSNumber) {
        self.maxLevel = maxLevel
        self.minLevel = minLevel
        self.numberOfBars = numberOfBars
        super.init()
    }
    
    convenience override init() {
        self.init(maxLevel: NSIntegerMax, minLevel : 0, numberOfBars : 0)
    }
    
    func powerLevelforValue(value : NSNumber) -> NSNumber {
        
        var division : NSNumber = (maxLevel.floatValue - minLevel.floatValue) / numberOfBars.floatValue
        for (var i : Int = 0; i < numberOfBars.integerValue; i++) {
            var lowLevel : NSNumber = minLevel.floatValue + division.floatValue * Float(i)
            var highLevel : NSNumber = minLevel.floatValue + division.floatValue * Float(i + 1)
            
            println("MAXLEVEL %f MINLEVEL %f VALUE %f", highLevel.floatValue, lowLevel.floatValue, value.floatValue)
            if (lowLevel.floatValue <= value.floatValue && value.floatValue < highLevel.floatValue) {
                return i
            }
            
        }
        return -1
    }
}
