//
//  RingModel.swift
//  Limit
//
//  Created by Rix Lai on 7/10/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import WatchKit

/*
 * A model that control ring movement
 */

open class RingModel: NSObject {
    fileprivate let RING_FPS: Double! = 60.0
    fileprivate let IMAGE_NAME: String = "single"
    
    fileprivate var isMoving: Bool! = false
    fileprivate var frame: Int = 0
    fileprivate var interfaceGroup: WKInterfaceGroup?
    
    /* Set interface group */
    open func setInterfaceGroup(_ interfaceGroup: inout WKInterfaceGroup) {
        self.interfaceGroup = interfaceGroup
        self.interfaceGroup?.setBackgroundImageNamed(IMAGE_NAME)
    }
    
    /* Random ring movement */
    open func randomData() {
        newData(Double(arc4random()%100+1), speedLimit: Double(arc4random()%150+1))
    }
    
    open func initialRing() {
        self.interfaceGroup?.setBackgroundImageNamed(IMAGE_NAME)
        self.frame = 0
    }
    
    /* Move ring according to new data */
    open func newData(_ speed: Double!, speedLimit: Double!) {
        // Ensure interface group exist
        guard(self.interfaceGroup != nil && speedLimit != -1.0) else {
            return
        }
        
        var destFrame: Int = Int( speed / speedLimit * 100 )
        
        // Ensure destination frame within range
        if(destFrame > 100) {
            destFrame = 100
        } else if(destFrame < 0) {
            destFrame = 0
        }
        
        moveFrame(destFrame)
        
    }
    
    /* Move to destination frame */
    fileprivate func moveFrame(_ destFrame: Int) {
        // Ensure needed to move
        if(destFrame == self.frame || self.isMoving) {
            return
        }
        
        // Lock
        self.isMoving = true
        
        let originFrame: Int = self.frame
        self.frame = destFrame
        
        var dir: Int, startFrame: Int, len: Int
        
        // Reverse frame needed
        if(originFrame > destFrame) {
            dir = -1
            startFrame = destFrame
            len = originFrame - destFrame + 1
            
        } else {
            // Normal frame
            dir = 1
            startFrame = originFrame
            len = destFrame - originFrame + 1
        }
        
        // Start animation
        self.interfaceGroup?.startAnimatingWithImages(in: NSMakeRange(startFrame, len), duration: Double( (Double(len)/RING_FPS)*Double(dir) ), repeatCount: 1)
        
        // Delay unlock
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64((Double(len)/RING_FPS) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: ({
            self.isMoving = false
        }))
    }
    
    
}
