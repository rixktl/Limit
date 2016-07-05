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

enum Status: Int {
    case Alert
    case Normal
    case Rest
}

internal protocol SpeedModelDelegate {
    func updateSpeedInfo(speed: Double!, speedLimit: Double?, unit: Bool!, status: Status)
}

public class SpeedModel: NSObject, OpenStreetMapModelDelegate, LocationManagerDelegate, SettingModelDelegate {
    
    private let osmModel: OpenStreetMapModel = OpenStreetMapModel()
    private let locManager: LocationModel = LocationModel()
    private let settingModel: SettingModel = SettingModel()
    private let MPH_TO_KPH_RATE: Double! = 1.609344
    private let LIMIT_OFFSET: Double! = 5.0
    
    // TODO: research, problem with delegate, it could be nil at some situation
    internal var delegate: SpeedModelDelegate!
    private var speed: Double?
    private var speedLimit: Double?
    private var settings: Settings! = Settings()
    private var lock: Bool! = false
    
    override init() {
        super.init()
        osmModel.delegate = self
        locManager.delegate = self
        settingModel.delegate = self
        // Check settings
        settingModel.didChangeSetting()
    }
    
    /* Start receiving location data */
    public func start() {
        self.lock = false
        locManager.start()
    }
    
    /* Stop receiving location data */
    public func stop() {
        self.lock = true
        locManager.stop()
    }
    
    /* Flip unit */
    public func flipUnit() {
        settingModel.flipUnit()
    }
    
    /* Convert MPH to KPH if needed */
    private func convertKPH(value: Double?) -> Double? {
        guard (value != nil) else {
            return nil
        }
        
        if(self.settings.isMPH!) {
            return value!
        } else {
            return value! * MPH_TO_KPH_RATE
        }
    }
    
    /* Offset speed limit in MPH if needed, should run before convertKPH */
    private func offsetSpeedLimit(speedlimit: Double?) -> Double? {
        guard (speedlimit != nil) else {
            return nil
        }
        
        if(self.settings.isExact!) {
            return speedlimit!
        } else {
            // Offset is in MPH
            return speedlimit! + LIMIT_OFFSET
        }
    }
    
    /* Get status code with speedlimit(offset added) */
    private func getStatus(limit: Double?) -> Status {
        //print("offseted-limit:", limit)
        //print("speed:", self.speed)
        //print("")
        
        // Both exist
        if(limit != nil && self.speed != nil) {
            // Over speed
            if(self.speed > limit) {
                return Status.Alert
                
            } else if(self.speed > 0 && self.speed <= limit){
                // Running with acceptable speed
                return Status.Normal
                
            } else {
                // At rest
                return Status.Rest
            }
            
        } else if (self.speed != nil) {
            // Only speed
            if(self.speed > 0) {
                return Status.Normal
            } else {
                return Status.Rest
            }
            
        } else {
            // Only limit or no data
            return Status.Rest
        }
    }
    
    /* Get final speed (always valid number) */
    private func getFinalSpeed() -> Double! {
        if(self.speed != nil) {
            return self.speed
        } else {
            return 0.0
        }
    }
    
    /* Update all info to handler */
    private func updateInfo() {
        guard (self.lock != true) else {
            return
        }
        
        delegate?.updateSpeedInfo(convertKPH(getFinalSpeed()), speedLimit:convertKPH(self.speedLimit), unit: self.settings.isMPH, status: getStatus(offsetSpeedLimit(self.speedLimit)))
    }
    
    /* Called when settings are updated */
    internal func updateSettings(settings: Settings!) {
        self.settings = settings
        // Update to handler
        updateInfo()
    }
    
    /* Called when speed limit is updated */
    internal func updateSpeedLimit(speedLimit: Double?) {
        // Update speed limit
        self.speedLimit = speedLimit
        // Update to handler
        updateInfo()
    }
    
    /* Called when location is updated */
    internal func locationUpdate(data: LocationData) {
        // Update speed
        self.speed = data.speed
        // Update to internal handler
        osmModel.newCoordinates(data)
        // Update to handler
        updateInfo()
    }

}
