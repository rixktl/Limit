//
//  AppCommunicationModel.swift
//  Limit
//
//  Created by Rix Lai on 7/4/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import WatchConnectivity

/*
 * A model that handle communication to iPhone
 */

enum WatchMessageMode: String {
    case Start = "START"
    case Stop = "STOP"
    case FlipUnit = "FLIP_UNIT"
}


internal protocol AppCommunicationModelDelegate {
    func updateSpeedInfo(_ speed: Double!, speedLimit: Double!, unit: Bool!, status: Int)
}

open class AppCommunicationModel: NSObject {
    
    internal var delegate: AppCommunicationModelDelegate!
    fileprivate let NOTIFICATION_NAME: String = "DID_RECEIVE_MESSAGE"
    fileprivate let INFO_NAME: String = "INFO"
    fileprivate let SPEED_DATA_NAMES: [String] = ["SPEED", "SPEED_LIMIT", "UNIT", "STATUS"]
    
    fileprivate var timer: Timer?
    fileprivate var didStart: Bool! = false
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessage), name: NSNotification.Name(rawValue: NOTIFICATION_NAME), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_NAME), object: nil)
    }
    
    /* Start communicating with iPhone */
    open func start() {
        // Ensure stopped before starting
        guard (self.didStart == false) else {
            return
        }
        
        self.didStart = true
        // Send message to start
        sendMessage([INFO_NAME:WatchMessageMode.Start.rawValue as AnyObject])
        // Setup spammer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(spamUntilConfirmation), userInfo: nil, repeats: true)
    }
    
    /* Spam to iPhone to prevent main view controller from running */
    internal func spamUntilConfirmation() {
        sendMessage([INFO_NAME:"NONE" as AnyObject])
    }
    
    /* Stop communcating with iPhone */
    open func stop() {
        // Ensure started before stopping
        guard (self.didStart == true) else {
            return
        }
        
        self.didStart = false
        sendMessage([INFO_NAME:WatchMessageMode.Stop.rawValue as AnyObject])
    }
    
    /* Request to flip unit */
    open func flipUnit() {
        // Ensure started before stopping
        guard (self.didStart == true) else {
            return
        }
        
        sendMessage([INFO_NAME:WatchMessageMode.FlipUnit.rawValue as AnyObject])
    }
    
    /* Called when receive new message from iPhone */
    internal func receiveMessage(_ notification: Notification) {
        let dict: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        // Check if receiving confirmation
        if(dict["INFO"] != nil && dict["INFO"]! as! String == "CONFIRMED") {
            if(timer != nil) {
                timer!.invalidate()
            }
            timer = nil
            
        } else {
            // Speed info received, updating
            // SpeedLimit will be -1 if not provided
            delegate!.updateSpeedInfo(dict[SPEED_DATA_NAMES[0]] as! Double!, speedLimit: dict[SPEED_DATA_NAMES[1]] as! Double!, unit: dict[SPEED_DATA_NAMES[2]] as! Bool!, status: dict[SPEED_DATA_NAMES[3]] as! Int)
        }
    }
    
    /* Send message to iPhone */
    fileprivate func sendMessage(_ message: [String: AnyObject]) {
        if(WCSession.default().isReachable) {
            print("Sending:",message)
            WCSession.default().sendMessage(message, replyHandler: nil, errorHandler: nil)
        } else {
            print("Unreachable")
        }
    }
    
    
    
}
