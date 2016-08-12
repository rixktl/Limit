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
    private var viewModel: ViewModel?
    private var ringModel: RingModel?
    
    /* Set app model */
    public func setAppModel(inout appModel: AppCommunicationModel) {
        self.appModel = appModel
    }
    
    /* Set view model */
    public func setViewModel(inout viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    /* Set ring model */
    public func setRingModel(inout ringModel: RingModel) {
        self.ringModel = ringModel
    }
    
    /* Pass new data for now status */
    public func newData(speed: Double!, speedLimit: Double!) {
        if(speed == 0 && status == Status.STARTED) {
            // Zero speed
            viewModel?.optionalStopView()
            status = Status.OPTIONAL_STOP
        } else if(speed != 0 && status != Status.STARTED) {
            status = Status.STARTED
        }
        
        // Activate ring only if status is started
        if(status == Status.STARTED) {
            ringModel?.newData(speed, speedLimit: speedLimit)
        }
    }
    
    /* Change model status according to status
        status indicates the current status,
        the following function perform a change from
        current status to new status(when user tapped)
     */
    public func update() {
        switch status {
            case Status.STARTED:
                // Tapped when it is started, should do nothing
                break
            
            case Status.STOPPED:
                // Tapped when it is stopped, should now start
                appModel?.start()
                viewModel?.startedView()
                status = Status.STARTED
                break
            
            case Status.OPTIONAL_STOP:
                // Tapped when it is optional stop, should now stop
                appModel?.stop()
                viewModel?.stoppedView()
                status = Status.STOPPED
                break
            
            default:
                break
        }
    }
    
}
