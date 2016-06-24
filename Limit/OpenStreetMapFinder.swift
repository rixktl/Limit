//
//  OpenStreetMapFinder.swift
//  Limit
//
//  Created by Rix Lai on 6/23/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/*
 * A finder to search for speed limit from data.
 * It should be run as async to prevent from blocking main thread
 */

internal protocol OpenStreetMapFinderDelegate {
    func limitUpdate(limit: Double?)
}

public class OpenStreetMapFinder {
    internal var data: OpenStreetMapData?
    internal var delegate: OpenStreetMapFinderDelegate?
    
    /* Make a async search */
    internal func searchWithCoordinates(coord: coordinates) {
        // TODO: make it real async
        asyncSearch(coord)
    }
    
    /* Search limit by coordinates */
    private func asyncSearch(coord: coordinates) {
        // Ensure data exist
        guard (data != nil) else {
            // Update limit as zero
            delegate?.limitUpdate(0.0)
            return
        }
        
        // TODO: search limit
    }
}
