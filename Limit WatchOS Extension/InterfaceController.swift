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
    
    private let MPH_NAME: String! = "M P H"
    private let KPH_NAME: String! = "K P H"
    private var appModel: AppCommunicationModel = AppCommunicationModel()
    private let ringModel: RingModel = RingModel()
    private let statusModel: StatusModel = StatusModel()
    private let alertModel: AlertModel = AlertModel()
    
    /* Called when unit button is clicked */
    @IBAction func unitButtonClicked() {
        // Flip unit
        appModel.flipUnit()
    }
    
    /* Called when group button is clicked */
    @IBAction func groupButtonClicked() {
        // Update status
        statusModel.update()
    }
    
    /* Updated by app communication model */
    internal func updateSpeedInfo(speed: Double!, speedLimit: Double!, unit: Bool!, status: Int) {
        // Update speed interface
        self.speedLabel.setText(  String( Int(round(speed)) )  )
        self.unitLabel.setText(unit! ? MPH_NAME : KPH_NAME)
        // Update data to models
        ringModel.newData(speed, speedLimit: speedLimit)
        statusModel.newData(speed)
        alertModel.newData(speed, speedLimit: speedLimit)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        // To show permission request
        //presentControllerWithName("LocationRequestView", context: nil)
        
        // Setup ring model
        // Pass by reference
        ringModel.setInterfaceGroup(&(ringGroup!))
        // Setup app model
        appModel.delegate = self
        // Setup status model
        statusModel.setAppModel( &(appModel) )
        
        // Start app model
        appModel.start()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func willDisappear() {
        appModel.stop()
    }

}
