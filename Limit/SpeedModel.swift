//
//  SpeedModel.swift
//  Limit
//
//  Created by Rix Lai on 6/24/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/*
 * A model that manage location data and OSM-Model
 */

internal protocol SpeedModelDelegate {
    func updateSpeedInfo(speed: Double?, speedLimit: Double?, unit: Bool!)
}

public class SpeedModel: NSObject, OpenStreetMapModelDelegate, LocationManagerDelegate {
    
    private let osmModel: OpenStreetMapModel = OpenStreetMapModel()
    private let locManager: LocationModel = LocationModel()
    private let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    private let MPH_TO_KPH_RATE: Double! = 1.609344
    private let UNIT_NAME: String! = "UNIT_IS_MPH"
    
    // TODO: research, problem with delegate, it could be nil at some situation
    internal var delegate: SpeedModelDelegate!
    private var speed: Double?
    private var speedLimit: Double?
    private var isMPH: Bool! = true
    private var isExact: Bool! = false
    
    override init() {
        super.init()
        osmModel.delegate = self
        locManager.delegate = self
        
        // Check unit once init
        self.checkUnitChanges()
        // Add self to observer for unit changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkUnitChanges), name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    deinit {
        // Remove observer when deallocate
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    /* Start receiving location data */
    public func start() {
        locManager.start()
    }
    
    /* Stop receiving location data */
    public func stop() {
        locManager.stop()
    }
    
    /* Flip unit */
    public func flipUnit() {
        // Boolean unit
        let boolUnit = userDefaults.boolForKey(UNIT_NAME)
        
        if (boolUnit == true) {
            userDefaults.setBool(false, forKey: UNIT_NAME)
            
        } else if (boolUnit == false) {
            userDefaults.setBool(true, forKey: UNIT_NAME)
        }
        
        checkUnitChanges()
    }
    
    /* Check unit changes */
    internal func checkUnitChanges() {
        // Get unit info
        let unit = userDefaults.objectForKey(UNIT_NAME)
        
        // Check if user setting for unit exist
        if(unit == nil) {
            // Write into setting, do not use synchronize
            userDefaults.setBool(true, forKey: UNIT_NAME)
            self.isMPH = true
            
        } else {
            // Boolean unit
            let boolUnit = userDefaults.boolForKey(UNIT_NAME)
            
            if (boolUnit == true) {
                self.isMPH = true
            
            } else if (boolUnit == false) {
                self.isMPH = false
            }
        }
        
        updateUnit()
    }
    
    /* Determine alert or not */
    private func checkAlert() {
        
    }
    
    /* Convert MPH to KPH if needed */
    private func convertKPH(value: Double?) -> Double? {
        guard (value != nil) else {
            return nil
        }
        
        if(isMPH!) {
            return value!
        } else {
            return value! * MPH_TO_KPH_RATE
        }
    }
    
    /* Update unit */
    private func updateUnit() {
        // Update to handler
        delegate?.updateSpeedInfo(convertKPH(self.speed), speedLimit: convertKPH(self.speedLimit), unit: self.isMPH)
    }
    
    /* Called when speed limit is updated */
    internal func updateSpeedLimit(speedLimit: Double?) {
        // Update speed limit
        self.speedLimit = speedLimit
        // Update to handler
        delegate?.updateSpeedInfo(convertKPH(self.speed), speedLimit: convertKPH(self.speedLimit), unit: self.isMPH)
    }
    
    /* Called when location is updated */
    internal func locationUpdate(data: LocationData) {
        // Update speed
        self.speed = data.speed
        // Update to internal handler
        osmModel.newCoordinates(data)
        // Update to handler
        delegate?.updateSpeedInfo(convertKPH(self.speed), speedLimit: convertKPH(self.speedLimit), unit: self.isMPH)
    }

}
