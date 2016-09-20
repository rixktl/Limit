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
    case started = 1
    // No speed
    case stopped = 2
    // Speed = 0
    case optional_STOP = 3
    // Initial status
    case undefined = -1
}

open class StatusModel: NSObject {
    fileprivate var status: Status = Status.undefined
    fileprivate var appModel: AppCommunicationModel?
    fileprivate var viewModel: ViewModel?
    fileprivate var ringModel: RingModel?
    fileprivate var alertModel: AlertModel?
    
    /* Set app model */
    open func setAppModel(_ appModel: inout AppCommunicationModel) {
        self.appModel = appModel
    }
    
    /* Set view model */
    open func setViewModel(_ viewModel: inout ViewModel) {
        self.viewModel = viewModel
    }
    
    /* Set ring model */
    open func setRingModel(_ ringModel: inout RingModel) {
        self.ringModel = ringModel
    }
    
    /* Set alert model */
    open func setAlertModel(_ alertModel: inout AlertModel) {
        self.alertModel = alertModel
    }
    
    /* Pass new data for now status */
    open func newData(_ speed: Double!, speedLimit: Double!, unitString: String!) {
        if(speed == 0.0 && status == Status.started) {
            // Zero speed
            viewModel?.optionalStopView(unitString)
            status = Status.optional_STOP
        } else if(speed != 0.0 && status != Status.started) {
            status = Status.started
            ringModel?.initialRing()
        }
        
        // Activate ring only if status is started
        if(status == Status.started) {
            ringModel?.newData(speed, speedLimit: speedLimit)
            viewModel?.normalView(speed, speedLimit: speedLimit, unit: unitString)
            alertModel?.enable()
            alertModel?.newData(speed, speedLimit: speedLimit)
        }
        
        if(status == Status.optional_STOP) {
            viewModel?.optionalStopView(unitString)
        }
    }
    
    open func initialStart() {
        update()
    }
    
    /* Change model status according to status
        status indicates the current status,
        the following function perform a change from
        current status to new status(when user tapped)
     */
    open func update() {
        switch status {
            
            case Status.undefined:
                // Initial state
                viewModel?.stoppedView()
                alertModel?.disable()
                status = Status.stopped
                break
            
            case Status.started:
                // Tapped when it is started, should do nothing
                break
            
            case Status.stopped:
                // Tapped when it is stopped, should now start
                appModel?.start()
                viewModel?.startedView()
                ringModel?.initialRing()
                status = Status.started
                break
            
            case Status.optional_STOP:
                // Tapped when it is optional stop, should now stop
                appModel?.stop()
                viewModel?.stoppedView()
                alertModel?.disable()
                status = Status.stopped
                break
        }
    }
    
}
