//
//  UIButtonExtension.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/30/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import UIKit

extension UIButton {
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.3
        pulse.fromValue = 0.95
        pulse.toValue = 1
        pulse.autoreverses = false
        pulse.repeatCount = 0
        pulse.initialVelocity = 0.3
        pulse.damping = 1
        
        layer.add(pulse, forKey: nil)
    }

    func flash() {
        let flash = CASpringAnimation(keyPath: "transform.")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        flash.autoreverses = false
        flash.repeatCount = 0
        
        layer.add(flash, forKey: nil)
    }
}
