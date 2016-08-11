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

public class WatchCommunicationModel: NSObject, SpeedModelDelegate {
    
    private let speedModel: SpeedModel = SpeedModel()
    private let INFO_NAME: String! = "INFO"
    
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
        let message: [String: AnyObject] = [DataLabel.Speed.rawValue:speed,
                                            DataLabel.SpeedLimit.rawValue: (speedLimit != nil ? speedLimit! : -1.0),
                                            DataLabel.Unit.rawValue: unit,
                                            DataLabel.Status.rawValue: status.rawValue]
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
