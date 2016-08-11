//
//  StatusModel.swift
//  Limit
//
//  Created by Rix Lai on 7/11/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/*
 * A model that control status whether app model should stop or start
 */

enum Status: Int {
    // Speed > 0
    case STARTED = 1
    // No speed
    case STOPPED = 2
    // Speed = 0
    case OPTIONAL_STOP = 3
    // Initial status
    case UNDEFINED = -1
}

public class StatusModel: NSObject {
    private var status: Status = Status.UNDEFINED
    private var appModel: AppCommunicationModel?
    
    /* Set app model */
    public func setAppModel(inout appModel: AppCommunicationModel) {
        self.appModel = appModel
    }
    
    /* Pass new data for now status */
    public func newData(speed: Double!) {
        if(speed == 0 && status == Status.STARTED) {
            status = Status.OPTIONAL_STOP
        } else if(speed != 0 && status != Status.STARTED) {
            status = Status.STARTED
        }
    }
    
    /* Change model status according to status */
    public func update() {
        switch status {
            case Status.STARTED:
                break
            
            case Status.STOPPED:
                appModel?.start()
                status = Status.STARTED
                break
            
            case Status.OPTIONAL_STOP:
                appModel?.stop()
                status = Status.STOPPED
                break
            
            default:
                break
        }
    }
    
}
