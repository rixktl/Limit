//
//  WatchCommunicationModel.swift
//  Limit
//
//  Created by Rix Lai on 7/4/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import WatchConnectivity

/*
 * A model that handle communication to Apple Watch
 */

enum WatchMessageMode: String {
    case Start = "START"
    case Stop = "STOP"
    case FlipUnit = "FLIP_UNIT"
}

enum DataLabel: String {
    case Speed = "SPEED"
    case SpeedLimit = "SPEED_LIMIT"
    case Unit = "UNIT"
    case Status = "STATUS"
}

open class WatchCommunicationModel: NSObject, SpeedModelDelegate {
    
    fileprivate let speedModel: SpeedModel = SpeedModel()
    fileprivate let INFO_NAME: String = "INFO"
    
    override init() {
        super.init()
        speedModel.delegate = self
    }
    
    // Need to implement a exit in case idle for a long time
    
    /* Receive new Message */
    open func newMessage(_ message: [String : Any]) {
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
    internal func updateSpeedInfo(_ speed: Double!, speedLimit: Double?, unit: Bool!, status: Status) {
        let message: [String: Any] = [DataLabel.Speed.rawValue:speed as Any,
                                            DataLabel.SpeedLimit.rawValue: (speedLimit != nil ? speedLimit! : -1.0 as Any),
                                            DataLabel.Unit.rawValue: unit,
                                            DataLabel.Status.rawValue: status.rawValue]
        // Send to Apple Watch
        sendMessage(message)
    }
    
    /* Send message to Apple Watch */
    fileprivate func sendMessage(_ message: [String : Any]) {
        if(WCSession.default().isReachable) {
            WCSession.default().sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
}
