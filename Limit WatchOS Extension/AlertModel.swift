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

public class AlertModel: NSObject {
    
    private var lock: Bool! = false
    private let VIBRATION_OFFSET: Double! = 3.0
    private let VIBRATION_TYPE: WKHapticType = WKHapticType.Click
    private let NULL_SPEEDLIMIT: Double! = -1.0
    /* Receive new data */
    public func newData(speed: Double!, speedLimit: Double!) {
        // Check if overspeed
        if(speed > speedLimit && speedLimit != NULL_SPEEDLIMIT) {
            vibrate()
        }
    }
    
    /* Request to vibrate */
    private func vibrate() {
        // Ensure status ok
        guard (self.lock != true) else {
            return
        }
        
        self.lock = true
        WKInterfaceDevice.currentDevice().playHaptic(VIBRATION_TYPE)
        
        // Delay unlock
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(VIBRATION_OFFSET * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), ({
            self.lock = false
        }))
    }
    
}
