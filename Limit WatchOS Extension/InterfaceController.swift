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
    
    fileprivate let MPH_NAME: String = "M P H"
    fileprivate let KPH_NAME: String = "K P H"
    fileprivate let statusModel: StatusModel = StatusModel()
    
    fileprivate var alertModel: AlertModel = AlertModel()
    fileprivate var appModel: AppCommunicationModel = AppCommunicationModel()
    fileprivate var ringModel: RingModel = RingModel()
    fileprivate var viewModel: ViewModel?
    
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
    internal func updateSpeedInfo(_ speed: Double!, speedLimit: Double!, unit: Bool!, status: Int) {
        // Update data to model
        statusModel.newData(speed, speedLimit: speedLimit, unitString: unit! ? MPH_NAME : KPH_NAME)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        
        // To show permission request
        //presentControllerWithName("LocationRequestView", context: nil)
        
        // Setup models, pass by ref
        viewModel = ViewModel(ig: &(ringGroup!), sLabel: &(speedLabel!), uLabel: &(unitLabel!))
        ringModel.setInterfaceGroup(&(ringGroup!))
        // Setup app model
        appModel.delegate = self
        // Setup status model
        statusModel.setAppModel( &(appModel) )
        statusModel.setRingModel(&(ringModel))
        statusModel.setAlertModel(&(alertModel))
        statusModel.setViewModel(&(viewModel!))
        
        statusModel.initialStart()
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
    }

}
