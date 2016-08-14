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
    func updateSpeedInfo(speed: Double!, speedLimit: Double!, unit: Bool!, status: Int)
}

public class AppCommunicationModel: NSObject {
    
    internal var delegate: AppCommunicationModelDelegate!
    private let NOTIFICATION_NAME: String! = "DID_RECEIVE_MESSAGE"
    private let INFO_NAME: String! = "INFO"
    private let SPEED_DATA_NAMES: [String!] = ["SPEED", "SPEED_LIMIT", "UNIT", "STATUS"]
    
    private var timer: NSTimer?
    private var didStart: Bool! = false
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveMessage), name: NOTIFICATION_NAME, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_NAME, object: nil)
    }
    
    /* Start communicating with iPhone */
    public func start() {
        // Ensure stopped before starting
        guard (self.didStart == false) else {
            return
        }
        
        self.didStart = true
        // Send message to start
        sendMessage([INFO_NAME:WatchMessageMode.Start.rawValue])
        // Setup spammer
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(spamUntilConfirmation), userInfo: nil, repeats: true)
    }
    
    /* Spam to iPhone to prevent main view controller from running */
    internal func spamUntilConfirmation() {
        sendMessage([INFO_NAME:"NONE"])
    }
    
    /* Stop communcating with iPhone */
    public func stop() {
        // Ensure started before stopping
        guard (self.didStart == true) else {
            return
        }
        
        self.didStart = false
        sendMessage([INFO_NAME:WatchMessageMode.Stop.rawValue])
    }
    
    /* Request to flip unit */
    public func flipUnit() {
        // Ensure started before stopping
        guard (self.didStart == true) else {
            return
        }
        
        sendMessage([INFO_NAME:WatchMessageMode.FlipUnit.rawValue])
    }
    
    /* Called when receive new message from iPhone */
    internal func receiveMessage(notification: NSNotification) {
        let dict: NSDictionary = notification.userInfo!
        
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
    private func sendMessage(message: [String: AnyObject]) {
        if(WCSession.defaultSession().reachable) {
            print("Sending:",message)
            WCSession.defaultSession().sendMessage(message, replyHandler: nil, errorHandler: nil)
        } else {
            print("Unreachable")
        }
    }
    
    
    
}