//
//  LocationModel.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import CoreLocation

/*
 * A model for handling location information update.
 * It runs in async manner
 */

internal protocol LocationManagerDelegate {
    func locationUpdate(data: LocationData)
}

public class LocationModel: NSObject, CLLocationManagerDelegate {
    
    internal var delegate: LocationManagerDelegate!
    internal var isMPH: Bool!
    private var address: String?
    private var locationManager: CLLocationManager?
    // Location update details
    private let GPS_DISTANCE_FILTER = kCLDistanceFilterNone
    private let GPS_ACCURACY = kCLLocationAccuracyBestForNavigation
    
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
            // Check for nil
            guard (speed != nil) else {
                return nil
            }
            // Return 0.0 when below zero, normal value otherwise
            if speed <= 0.0 {
                return 0.0
            } else {
                return fabs(speed!)
            }
        }
        
        /* Return speed in MPH */
        func getMPH() -> Double? {
            // Check for nil
            guard (speed != nil) else {
                return nil
            }
            
            return getRealValue(speed)! * MPHrate
        }
        
        /* Return speed in KPH */
        func getKPH() -> Double? {
            // Check for nil
            guard (speed != nil) else {
                return nil
            }
            
            return getRealValue(speed)! * KPHrate
        }
    }
    
    /* Initialization without delegate */
    override public convenience init() {
        self.init(delegate: nil)
    }
    
    /* Initialization */
    internal init(delegate: LocationManagerDelegate!) {
        super.init()
        
        // Set up location manager
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        // Preferences
        locationManager!.distanceFilter = GPS_DISTANCE_FILTER
        locationManager!.desiredAccuracy = GPS_ACCURACY
        
        // Delegate for update result(callback)
        self.delegate = delegate!
        
        // Default unit
        self.isMPH = true
    }
    
    /* Convert location to state */
    private func locationToState() {
        
        // Return if nil
        guard (locationManager?.location != nil) else {
            return
        }
        
        // Reserve geocode from location
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation((locationManager?.location)!, completionHandler: {(placemarks, error) -> Void in
            // Check if error exist
            if error != nil {
                // TODO: Error handling
            }
            // Check if placemarks exist
            guard (placemarks != nil) else {
                return
            }
            // Check if single placemark exist
            guard (placemarks!.count >= 0) else {
                return
            }
            let placemark: CLPlacemark = placemarks![0]
            self.address = placemark.administrativeArea
        })
        
    }
    
    /* Start updating location */
    public func start() {
        // Request authorization if needed
        locationManager?.requestAlwaysAuthorization()
        // Start receiving location update
        locationManager?.startUpdatingLocation()
        
    }
    
    /* Stop updating location */
    public func stop() {
        locationManager?.stopUpdatingLocation()
    }
    
    /* Receives update */
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Check if location details exist
        guard (locations.count > 0) else {
            return
        }
        
        let info: CLLocation = locations[locations.endIndex - 1]
        let v: velocity = velocity(speed: info.speed, direction: info.course)
        let speed: Double?
        
        // Unit check
        if(isMPH!) {
            speed = v.getMPH()
        } else {
            speed = v.getKPH()
        }
        
        // Covert location to state
        locationToState()
        
        // Construct data
        let data: LocationData = LocationData(speed: speed, latitude: info.coordinate.latitude, longitude: info.coordinate.longitude, state: address)
        
        // Update to handler
        delegate!.locationUpdate(data)
        
    }
    
    /*  Receives error */
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // TODO: Error handling
    }
    
}
