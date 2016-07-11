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

public class RingModel: NSObject {
    private let RING_FPS: Double! = 60.0
    private let IMAGE_NAME: String! = "single"
    
    private var isMoving: Bool! = false
    private var frame: Int = 0
    private var interfaceGroup: WKInterfaceGroup?
    
    /* Set interface group */
    public func setInterfaceGroup(inout interfaceGroup: WKInterfaceGroup) {
        self.interfaceGroup = interfaceGroup
        self.interfaceGroup?.setBackgroundImageNamed(IMAGE_NAME)
    }
    
    /* Random ring movement */
    public func randomData() {
        newData(Double(rand()%100+1), speedLimit: Double(rand()%150+1))
    }
    
    /* Move ring according to new data */
    public func newData(speed: Double!, speedLimit: Double!) {
        // Ensure interface group exist
        guard(self.interfaceGroup != nil) else {
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
    private func moveFrame(destFrame: Int) {
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
        self.interfaceGroup?.startAnimatingWithImagesInRange(NSMakeRange(startFrame, len), duration: Double( (Double(len)/RING_FPS)*Double(dir) ), repeatCount: 1)
        
        // Delay unlock
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((Double(len)/RING_FPS) * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), ({
            self.isMoving = false
        }))
    }
    
    
}
