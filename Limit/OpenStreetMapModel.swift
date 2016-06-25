//
//  OpenStreetMapModel.swift
//  Limit
//
//  Created by Rix Lai on 6/23/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/*
 * A model that manage OSM-XAPI and OSM-Nominatim and takes current location data
 */

internal protocol OpenStreetMapModelDelegate {
    func updateSpeedLimit(speedLimit: Double?)
}

public class OpenStreetMapModel: NSObject, OpenStreetMapParserDelegate, OpenStreetMapFinderDelegate, OpenStreetMapReverseGeoParserDelegate {
    
    private let osmParser: OpenStreetMapParser! = OpenStreetMapParser()
    private let osmFinder: OpenStreetMapFinder! = OpenStreetMapFinder()
    private let osmReverseGeo: OpenStreetMapReverseGeoParser! = OpenStreetMapReverseGeoParser()
    
    internal var delegate: OpenStreetMapModelDelegate!
    private var locationData: LocationData?
    private var reverseGeoData: OpenStreetMapReverseGeoData?
    private var upperBound: coordinates?
    private var lowerBound: coordinates?
    
    override public init() {
        // Set up parser
        osmParser.offsetLatitude = 0.01
        osmParser.offsetLongitude = 0.01
        // Set up finder
        osmFinder.offsetDegree = 5.0
        super.init()
        // Set up delegate
        osmParser.delegate = self
        osmFinder.delegate = self
        osmReverseGeo.delegate = self
    }
    
    /* Attempt to request update */
    private func request() {
        
        // Always get reverse geo
        osmReverseGeo.request(self.locationData?.coord)
        
        // Ensure non nil
        guard (checkBound() != nil) else {
            // Request new data
            osmParser.request(self.locationData?.coord)
            return
        }
        
        // See if Bound check fail
        if(!checkBound()! || (osmParser.coord!.latitude != self.locationData!.coord!.latitude || osmParser.coord!.longitude != self.locationData!.coord!.longitude) ) {
            // Request new data
            osmParser.request(self.locationData?.coord)
        } else {
            // Search within data using id
            osmFinder.asyncSearch()
        }
    }
    
    /* Check if coordinates within bound */
    private func checkBound() -> Bool? {
        // Ensure non nil
        guard (self.locationData?.coord != nil && upperBound != nil && lowerBound != nil) else {
            return nil
        }
        
        // return boolean result
        return (self.locationData?.coord!.latitude < upperBound!.latitude &&
            self.locationData?.coord!.longitude < upperBound!.latitude &&
            self.locationData?.coord!.latitude > lowerBound!.latitude &&
            self.locationData?.coord!.longitude > lowerBound?.longitude)
    }
    
    /* Set bounded offset for parser */
    internal func setBoundedOffset(offsetLatitude: Double!, offsetLongitude: Double!) {
        osmParser.offsetLatitude = offsetLatitude
        osmParser.offsetLongitude = offsetLongitude
    }
    
    /* Update new coordinate */
    internal func newCoordinates(data: LocationData) {
        guard (data.coord?.latitude != nil && data.coord?.longitude != nil) else {
            return
        }
        
        self.locationData = data
        request()
    }
    
    /* Receives update from reverse geo parser */
    internal func updateReverseGeoResult(data: OpenStreetMapReverseGeoData!) {
        // Update local data
        self.reverseGeoData = data
    }
    
    /* Receives update from parser */
    internal func updateData(data: OpenStreetMapData!) {
        // Update data for finder
        osmFinder.data = data
        osmFinder.locationData = locationData
        osmFinder.reverseGeoData = reverseGeoData
        
        // Update local boundary
        upperBound = coordinates(latitude: osmParser.coord!.latitude + osmParser.offsetLatitude, longitude: osmParser.coord!.longitude + osmParser.offsetLongitude)
        lowerBound = coordinates(latitude: osmParser.coord!.latitude - osmParser.offsetLatitude, longitude: osmParser.coord!.longitude - osmParser.offsetLongitude)
        
        // Search speed limit 
        osmFinder.asyncSearch()
    }
    
    /* Receives update from finder */
    internal func updateSpeedLimit(speedLimit: Double?) {
        // Update to handler
        self.delegate.updateSpeedLimit(speedLimit)
    }
}
