//
//  OpenStreetMapModel.swift
//  Limit
//
//  Created by Rix Lai on 6/23/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

internal protocol OpenStreetMapModelDelegate {
    func updateSpeedLimit(speedLimit: Double?)
}

public class OpenStreetMapModel: NSObject, OpenStreetMapParserDelegate, OpenStreetMapFinderDelegate, OpenStreetMapReverseGeoParserDelegate {
    
    let osmParser: OpenStreetMapParser! = OpenStreetMapParser()
    let osmFinder: OpenStreetMapFinder! = OpenStreetMapFinder()
    let osmReverseGeo: OpenStreetMapReverseGeoParser! = OpenStreetMapReverseGeoParser()
    
    var delegate: OpenStreetMapModelDelegate!
    var coord: coordinates?
    var direction: Double?
    var ref: String?
    var id: String?
    var name: String?
    var upperBound: coordinates?
    var lowerBound: coordinates?
    
    
    /* TODO: bound coord check (exceed->request new chunk) */
    
    override public init() {
        // Set up parser
        osmParser.offsetLatitude = 0.01
        osmParser.offsetLongitude = 0.01
        // Set up finder
        osmFinder.offsetDegree = 5.0
        // Local init
        coord = nil
        upperBound = nil
        lowerBound = nil
        super.init()
        // Set up delegate
        osmParser.delegate = self
        osmFinder.delegate = self
        osmReverseGeo.delegate = self
    }
    
    /* Attempt to request update */
    private func request() {
        // Ensure non nil
        guard (checkBound() != nil) else {
            // Request new data
            osmReverseGeo.request(coord!)
            osmParser.request(coord!)
            return
        }
        
        // See if Bound check fail
        if(!checkBound()! || (osmParser.coord!.latitude != coord!.latitude || osmParser.coord!.longitude != coord!.longitude) ) {
            // Request new data
            osmReverseGeo.request(coord!)
            osmParser.request(coord!)
        } else {
            // Search within data using id
            osmReverseGeo.request(coord!)
            osmFinder.asyncSearch()
        }
    }
    
    /* Check if coordinates within bound */
    private func checkBound() -> Bool? {
        // Ensure non nil
        guard (coord != nil && upperBound != nil && lowerBound != nil) else {
            return nil
        }
        
        // return boolean result
        return (coord!.latitude < upperBound!.latitude &&
            coord!.longitude < upperBound!.latitude &&
            coord!.latitude > lowerBound!.latitude &&
            coord!.longitude > lowerBound?.longitude)
    }
    
    /* Set bounded offset for parser */
    internal func setBoundedOffset(offsetLatitude: Double!, offsetLongitude: Double!) {
        osmParser.offsetLatitude = offsetLatitude
        osmParser.offsetLongitude = offsetLongitude
    }
    
    /* Update new coordinate */
    internal func newCoordinates(coord: coordinates?, direction: Double?, ref: String?) {
        guard (coord != nil) else {
            return
        }
        
        self.coord = coord!
        self.direction = direction
        self.ref = ref
        request()
    }
    
    /* Receives update from reverse geo parser */
    internal func updateReverseGeoResult(id: String!, name: String!) {
        // Update local data
        self.id = id
        self.name = name
    }
    
    /* Receives update from parser */
    internal func updateData(data: OpenStreetMapData!) {
        // Update data for finder
        osmFinder.data = data
        osmFinder.coord = coord
        osmFinder.id = id
        osmFinder.name = name
        osmFinder.direction = direction
        osmFinder.ref = ref
        
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
