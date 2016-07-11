//
//  InterfaceController.swift
//  Limit WatchOS Extension
//
//  Created by Rix Lai on 7/4/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, AppCommunicationModelDelegate {

    @IBOutlet var ringGroup: WKInterfaceGroup!
    @IBOutlet var speedLabel: WKInterfaceLabel!
    @IBOutlet var unitLabel: WKInterfaceLabel!
    
    private let appModel: AppCommunicationModel = AppCommunicationModel()
    private let ringModel: RingModel = RingModel()
    
    internal func updateSpeedInfo(speed: Double!, speedLimit: Double!, unit: Bool!, status: Int) {
        print("speed:", speed)
        print("speedLimit:", speedLimit)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        // Setup ring model
        // Pass by reference
        ringModel.setInterfaceGroup(&(ringGroup!))
        
        // Setup app model
        appModel.delegate = self
        appModel.start()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(60 * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), ({
            self.appModel.stop()
        }))
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
