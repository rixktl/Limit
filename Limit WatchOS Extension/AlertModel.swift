//
//  AlertModel.swift
//  Limit
//
//  Created by Rix Lai on 8/10/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import WatchKit

/* A model that control vibration alert */

open class AlertModel: NSObject {
    
    fileprivate var isEnabled: Bool! = true
    fileprivate var lock: Bool! = false
    fileprivate let VIBRATION_OFFSET: Double! = 3.0
    fileprivate let VIBRATION_TYPE: WKHapticType = WKHapticType.click
    fileprivate let NULL_SPEEDLIMIT: Double! = -1.0
    /* Receive new data */
    open func newData(_ speed: Double!, speedLimit: Double!) {
        // Check if overspeed
        if(speed > speedLimit && speedLimit != NULL_SPEEDLIMIT) {
            vibrate()
        }
    }
    
    open func enable() {
        self.isEnabled = true
    }
    
    open func disable() {
        self.isEnabled = false
    }
    
    /* Request to vibrate */
    fileprivate func vibrate() {
        // Ensure status ok
        guard (self.lock != true && self.isEnabled) else {
            return
        }
        
        self.lock = true
        WKInterfaceDevice.current().play(VIBRATION_TYPE)
        
        // Delay unlock
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(VIBRATION_OFFSET * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: ({
            self.lock = false
        }))
    }
    
}
