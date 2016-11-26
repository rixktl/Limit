//
//  SpeedModel.swift
//  Limit
//
//  Created by Rix Lai on 6/24/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


/*
 * A model that manage location data and OSM-Model
 */

enum Status: Int {
    case alert
    case normal
    case rest
}

internal protocol SpeedModelDelegate {
    func updateSpeedInfo(_ speed: Double!, speedLimit: Double?, unit: Bool!,
                         status: Status)
}

open class SpeedModel: NSObject, OpenStreetMapModelDelegate,
                       LocationManagerDelegate, SettingModelDelegate, GoogleMapModelDelegate {
    
    fileprivate let osmModel: OpenStreetMapModel = OpenStreetMapModel()
    fileprivate let googleModel: GoogleMapModel = GoogleMapModel()
    fileprivate let locManager: LocationModel = LocationModel()
    fileprivate let settingModel: SettingModel = SettingModel()
    fileprivate let MPH_TO_KPH_RATE: Double! = 1.609344
    fileprivate let LIMIT_OFFSET: Double! = 5.0
    
    // TODO: research, problem with delegate, it could be nil at some situation
    internal var delegate: SpeedModelDelegate!
    fileprivate var speed: Double?
    fileprivate var speedLimit: Double?
    fileprivate var settings: Settings! = Settings()
    fileprivate var lock: Bool! = false
    
    override init() {
        super.init()
        osmModel.delegate = self
        googleModel.delegate = self
        locManager.delegate = self
        settingModel.delegate = self
        // Check settings
        settingModel.didChangeSetting()
    }
    
    /* Start receiving location data */
    open func start() {
        self.lock = false
        locManager.start()
    }
    
    /* Stop receiving location data */
    open func stop() {
        self.lock = true
        locManager.stop()
    }
    
    /* Flip unit */
    open func flipUnit() {
        settingModel.flipUnit()
    }
    
    /* Convert MPH to KPH if needed */
    fileprivate func convertKPH(_ value: Double?) -> Double? {
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
    fileprivate func offsetSpeedLimit(_ speedlimit: Double?) -> Double? {
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
    fileprivate func getStatus(_ limit: Double?) -> Status {
        //print("offseted-limit:", limit)
        //print("speed:", self.speed)
        //print("")
        
        // Both exist
        if(limit != nil && self.speed != nil) {
            // Over speed
            if(self.speed > limit) {
                return Status.alert
                
            } else if(self.speed > 0 && self.speed <= limit){
                // Running with acceptable speed
                return Status.normal
                
            } else {
                // At rest
                return Status.rest
            }
            
        } else if (self.speed != nil) {
            // Only speed
            if(self.speed > 0) {
                return Status.normal
            } else {
                return Status.rest
            }
            
        } else {
            // Only limit or no data
            return Status.rest
        }
    }
    
    /* Get final speed (always valid number) */
    fileprivate func getFinalSpeed() -> Double! {
        if(self.speed != nil) {
            return self.speed
        } else {
            return 0.0
        }
    }
    
    /* Update all info to handler */
    fileprivate func updateInfo() {
        guard (self.lock != true) else {
            return
        }
        
        delegate?.updateSpeedInfo(convertKPH(getFinalSpeed()),
                                  speedLimit:convertKPH(self.speedLimit),
                                  unit: self.settings.isMPH,
                                  status: getStatus(
                                          offsetSpeedLimit(self.speedLimit))  )
    }
    
    /* Called when settings are updated */
    internal func updateSettings(_ settings: Settings!) {
        self.settings = settings
        // Update to handler
        updateInfo()
    }
    
    /* Called when speed limit is updated */
    internal func updateSpeedLimit(_ speedLimit: Double?) {
        // Update speed limit
        self.speedLimit = speedLimit
        // Update to handler
        updateInfo()
    }
    
    /* Called when location is updated */
    internal func locationUpdate(_ data: LocationData) {
        // Update speed
        self.speed = data.speed
        // Update to internal handler
        osmModel.newCoordinates(data)
        googleModel.request(data.coord)
        // Update to handler
        updateInfo()
    }

}
