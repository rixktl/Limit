//
//  WatchCommunicationModel.swift
//  Limit
//
//  Created by Rix Lai on 7/4/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import WatchConnectivity

enum WatchMessageMode: String {
    case Start = "START"
    case Stop = "STOP"
    case FlipUnit = "FLIP_UNIT"
}

public class WatchCommunicationModel: NSObject, SpeedModelDelegate {
    
    private let speedModel: SpeedModel = SpeedModel()
    private let INFO_NAME: String! = "INFO"
    private let SPEED_DATA_NAMES: [String!] = ["SPEED", "SPEED_LIMIT", "UNIT", "STATUS"]
    
    override init() {
        super.init()
        speedModel.delegate = self
    }
    
    // Need to implement a exit in case idle for a long time
    
    /* Receive new Message */
    public func newMessage(message: [String : AnyObject]) {
        switch message[INFO_NAME] {
            
            case WatchMessageMode.Start.rawValue as String:
                speedModel.start()
                break
            
            case WatchMessageMode.Stop.rawValue as String:
                speedModel.stop()
                break
            
            case WatchMessageMode.FlipUnit.rawValue as String:
                speedModel.flipUnit()
                break
            
            default:
                break
        }
    }
    
    /* Updated by speed model */
    internal func updateSpeedInfo(speed: Double!, speedLimit: Double?, unit: Bool!, status: Status) {
        let message: [String: AnyObject] = [SPEED_DATA_NAMES[0]:speed,
                                            SPEED_DATA_NAMES[1]: (speedLimit != nil ? speedLimit! : -1.0),
                                            SPEED_DATA_NAMES[2]: unit,
                                            SPEED_DATA_NAMES[3]: status.rawValue]
        // Send to Apple Watch
        sendMessage(message)
    }
    
    /* Send message to Apple Watch */
    private func sendMessage(message: [String : AnyObject]) {
        if(WCSession.defaultSession().reachable) {
            WCSession.defaultSession().sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
}
