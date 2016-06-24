//
//  OpenStreetMapModel.swift
//  Limit
//
//  Created by Rix Lai on 6/23/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

internal protocol OpenStreetMapModelDelegate {
    func limitUpdate(limit: Double?)
}

public class OpenStreetMapModel: NSObject, OpenStreetMapParserDelegate, OpenStreetMapFinderDelegate {
    
    let osmParser: OpenStreetMapParser = OpenStreetMapParser()
    let osmFinder: OpenStreetMapFinder = OpenStreetMapFinder()
    var delegate: OpenStreetMapModelDelegate!
    
    override public init() {
        // Set up parser
        osmParser.offsetLatitude = 0.01
        osmParser.offsetLongitude = 0.01
        super.init()
    }
    
    /* Set bounded offset for parser */
    internal func setBoundedOffset(offsetLatitude: Double!, offsetLongitude: Double!) {
        osmParser.offsetLatitude = offsetLatitude
        osmParser.offsetLongitude = offsetLongitude
    }
    
    /* Request search with coordinates */
    internal func searchWithCoordinates(coord: coordinates) {
        osmFinder.searchWithCoordinates(coord)
    }
    
    /* Receives update from parser */
    internal func dataUpdate(data: OpenStreetMapData) {
        // Update data for finder
        osmFinder.data = data
    }
    
    /* Receives update from finder */
    internal func limitUpdate(limit: Double?) {
        self.delegate.limitUpdate(limit)
    }
}
