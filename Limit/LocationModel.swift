//
//  LocationModel.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate{
    func locationUpdate(data: LocationData)
}

class LocationModel: NSObject, CLLocationManagerDelegate {
    
    var address: String?
    var isMPH: Bool!
    var locationManager: CLLocationManager?
    var delegate: LocationManagerDelegate?
    // Location detail
    let gpsDistanceFilter = kCLDistanceFilterNone
    let gpsAccuracy = kCLLocationAccuracyBestForNavigation
    
    /* Manager raw velocity */
    struct velocity {
        var speed: Double?
        var direction: Double?
        // Convert rate
        let MPHrate: Double! = 2.23694
        let KPHrate: Double! = 3.6
        
        /* Initialize with speed(magnitude) and direction */
        init(speed: Double?, direction: Double?) {
            self.speed = speed
            self.direction = direction
        }
        
        /* Return a absolute value */
        func getRealValue(speed: Double?) -> Double? {
            
            guard (speed == nil) else{
                return nil
            }
            
            if speed < 0.0 {
                return 0.0
            }else{
                return fabs(speed!)
            }
        }
        
        /* Return speed in MPH */
        func getMPH() -> Double? {
            
            guard (speed == nil) else{
                return nil
            }
            
            return getRealValue(speed)! * MPHrate
        }
        
        /* Return speed in KPH */
        func getKPH() -> Double? {
            
            guard (speed == nil) else{
                return nil
            }
            
            return getRealValue(speed)! * KPHrate
        }
    }
    
    /* Initialization */
    override init() {
        super.init()
        // Set up location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // Preferences
        locationManager?.distanceFilter = gpsDistanceFilter
        locationManager?.desiredAccuracy = gpsAccuracy
        
        // Default unit
        self.isMPH = true
    }
    
    /* Start receiving update */
    func start() {
        // Request authorization if needed
        locationManager?.requestAlwaysAuthorization()
        // Start receiving location update
        locationManager?.startUpdatingLocation()
    }
    
    /* Stop updating location */
    func stop() {
        locationManager?.stopUpdatingLocation()
    }
    
    /* Receiving update */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        // To Do: Check if confirmed to protocol (CLLocation)
        let info: CLLocation = locations[locations.endIndex]
        let v: velocity = velocity(speed: info.speed, direction: info.course)
        let speed: Double?
        
        // Unit check
        if(isMPH!) {
            speed = v.getMPH()
        }else{
            speed = v.getKPH()
        }
    
        // To Do: latitude, longitude, state
        let data: LocationData = LocationData(speed: speed, latitude: nil, longitude: nil, state: nil)
        
        // Update to handler
        delegate?.locationUpdate(data)
        
    }
    
}