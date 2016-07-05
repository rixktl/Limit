//
//  AppCommunicationModel.swift
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


internal protocol AppCommunicationModelDelegate {
    func updateSpeedInfo(speed: Double!, speedLimit: Double!, unit: Bool!, status: Int)
}

public class AppCommunicationModel: NSObject {
    
    internal var delegate: AppCommunicationModelDelegate!
    private let NOTIFICATION_NAME: String! = "DID_RECEIVE_MESSAGE"
    private let INFO_NAME: String! = "INFO"
    private let SPEED_DATA_NAMES: [String!] = ["SPEED", "SPEED_LIMIT", "UNIT", "STATUS"]
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveMessage), name: NOTIFICATION_NAME, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_NAME, object: nil)
    }
    
    public func start() {
        sendMessage([INFO_NAME:WatchMessageMode.Start.rawValue])
    }
    
    public func stop() {
        sendMessage([INFO_NAME:WatchMessageMode.Stop.rawValue])
    }
    
    public func flipUnit() {
        sendMessage([INFO_NAME:WatchMessageMode.FlipUnit.rawValue])
    }
    
    /* Called when receive new message from iPhone */
    internal func receiveMessage(notification: NSNotification) {
        let dict: NSDictionary = notification.userInfo!
        print("Receiving:", dict)
        delegate!.updateSpeedInfo(dict[SPEED_DATA_NAMES[0]] as! Double!, speedLimit: dict[SPEED_DATA_NAMES[1]] as! Double!, unit: dict[SPEED_DATA_NAMES[2]] as! Bool!, status: dict[SPEED_DATA_NAMES[3]] as! Int)
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