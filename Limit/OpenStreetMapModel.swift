//
//  OpenStreetMapModel.swift
//  Limit
//
//  Created by Rix Lai on 6/23/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/* Not tested yet */

internal protocol OpenStreetMapModelDelegate {
    func updateSpeedLimit(speedLimit: Double?)
}

public class OpenStreetMapModel: NSObject, OpenStreetMapParserDelegate, OpenStreetMapFinderDelegate {
    
    let osmParser: OpenStreetMapParser! = OpenStreetMapParser()
    let osmFinder: OpenStreetMapFinder! = OpenStreetMapFinder()
    var delegate: OpenStreetMapModelDelegate!
    var coord: coordinates?
    var direction: Double?
    var ref: String?
    var upperBound: coordinates?
    var lowerBound: coordinates?
    
    /* TODO: bound coord check (exceed->request new chunk) */
    
    override public init() {
        // Set up parser
        osmParser.offsetLatitude = 0.01
        osmParser.offsetLongitude = 0.01
        osmFinder.offsetDegree = 5.0
        coord = nil
        upperBound = nil
        lowerBound = nil
        super.init()
        osmParser.delegate = self
        osmFinder.delegate = self
    }
    
    /* Attempt to request update */
    private func request() {
        // Ensure non nil
        guard (checkBound() != nil) else {
            // Request new data
            osmParser.request(coord!)
            return
        }
        
        // See if Bound check fail
        if(!checkBound()!) {
            // Request new data
            osmParser.request(coord!)
        } else {
            // Search within data
            osmFinder.searchWithCoordinates(coord!, direction: direction!, ref: ref)
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
        guard (coord != nil && direction != nil) else {
            return
        }
        
        self.coord = coord!
        self.direction = direction
        self.ref = ref
        request()
    }
    
    /* Receives update from parser */
    internal func updateData(data: OpenStreetMapData!) {
        // Update data for finder
        osmFinder.data = data
        // Update boundary
        upperBound = coordinates(latitude: osmParser.coord!.latitude + osmParser.offsetLatitude, longitude: osmParser.coord!.longitude + osmParser.offsetLongitude)
        lowerBound = coordinates(latitude: osmParser.coord!.latitude - osmParser.offsetLatitude, longitude: osmParser.coord!.longitude - osmParser.offsetLongitude)
        // Search speed limit if able to
        if (osmFinder.data != nil && coord != nil && direction != nil) {
            osmFinder.searchWithCoordinates(coord!, direction: direction!, ref: ref)
        }
    }
    
    /* Receives update from finder */
    internal func updateSpeedLimit(speedLimit: Double?) {
        self.delegate.updateSpeedLimit(speedLimit)
    }
}
