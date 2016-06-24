//
//  OpenStreetMapFinder.swift
//  Limit
//
//  Created by Rix Lai on 6/23/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

/* Not tested yet */

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
    internal var delegate: OpenStreetMapFinderDelegate!
    
    private let MAXSPEED_TAG_IDENTIFIER: String! = "maxspeed"
    private let HIGHWAY_TAG_IDENTIFIER: String! = "highway"
    
    private let RESIDENTIAL_VALUE_IDENTIFIER: String! = "residential"
    private let SERVICE_VALUE_IDENTIFIER: String! = "service"
    private let SECONDARY_VALUE_IDENTIFIER: String! = "secondary"
    private let TERTIARY_VALUE_IDENTIFIER: String! = "tertiary"
    private let PRIMARY_VALUE_IDENTIFIER: String! = "primary"
    private let FREEWAY_VALUE_IDENTIFIER: String! = "freeway"
    private let MOTORWAY_VALUE_IDENTIFIER: String! = "motorway"
    private let TRUNK_VALUE_IDENTIFIER: String! = "trunk"
    
    /* Make a async search */
    internal func searchWithCoordinates(coord: coordinates) {
        // TODO: make it real async
        asyncSearch(coord)
    }
    
    /* Search limit by coordinates */
    private func asyncSearch(coord: coordinates) {
        // Ensure data exist
        guard (data != nil && data!.ways != nil) else {
            // Update limit as zero
            delegate!.limitUpdate(0.0)
            return
        }
        
        // Find nearest way
        var wayResult: [Int] = searchNearestWay(coord)
        
        // Attempt to get maxspeed from way's tag
        var limit: Double? = extractLimitFromWayTag(data!.ways![wayResult[0]])
        
        if(limit != nil) {
            delegate.limitUpdate(limit)
            return
        }
        
        // Attempt to get maxspeed from node's tag
        limit = extractLimitFromNodeTag(data!.ways![wayResult[0]].subNode![wayResult[1]])
        
        if(limit != nil) {
            delegate.limitUpdate(limit)
            return
        }
        
        // Attempt to get maxspeed from near node's tag
        let index: Int = (wayResult[2] == 1 ? wayResult[1] + 1 : wayResult[1] - 1)
        
        limit = extractLimitFromNodeTag(data!.ways![wayResult[0]].subNode![index])
        
        if(limit != nil) {
            delegate.limitUpdate(limit)
            return
        }
        
        // Attempt to get maxspeed from the rest node's tag
        for n in data!.ways![wayResult[0]].subNode! {
            limit = extractLimitFromNodeTag(n)
            if(limit != nil) {
                delegate.limitUpdate(limit)
                return
            }
        }
        
        // Attempt to match speed limit with way's tag type
        limit = getLimitFromWayTagType(data!.ways![wayResult[0]])
        
        if(limit != nil) {
            delegate.limitUpdate(limit)
            return
        }
        
        // Attempt to match speed limit with node's tag type
        limit = getLimitFromNodeTagType(data!.ways![wayResult[0]].subNode![wayResult[1]])
        
        if(limit != nil) {
            delegate.limitUpdate(limit)
            return
        }
        
        // Attempt to match speed limit with near node's tag type
        limit = getLimitFromNodeTagType(data!.ways![wayResult[0]].subNode![index])
        
        if(limit != nil) {
            delegate.limitUpdate(limit)
            return
        }
        
        
    }
    
    /* Convert type to speed limit */
    private func typeToLimit(type: String?) -> Double? {
        // Ensure type exist
        guard (type != nil) else {
            return nil
        }
        
        switch type! {
        case RESIDENTIAL_VALUE_IDENTIFIER, SERVICE_VALUE_IDENTIFIER:
            return 25.0
        case SECONDARY_VALUE_IDENTIFIER, TERTIARY_VALUE_IDENTIFIER:
            return 30.0
        case PRIMARY_VALUE_IDENTIFIER, FREEWAY_VALUE_IDENTIFIER, MOTORWAY_VALUE_IDENTIFIER, TRUNK_VALUE_IDENTIFIER:
            return 60.0
        default:
            return nil
        }
    }
    
    private func getLimitFromNodeTagType(n: node) -> Double? {
        // Ensure tag exist
        guard (n.subTag != nil) else {
            return nil
        }
        
        for tg in n.subTag! {
            if(tg.key == HIGHWAY_TAG_IDENTIFIER) {
                return typeToLimit(tg.value)
            }
        }
        
        return nil
    }
    
    private func getLimitFromWayTagType(w: way) -> Double? {
        // Ensure tag exist
        guard (w.subTag != nil) else {
            return nil
        }
        
        for tg in w.subTag! {
            if(tg.key == HIGHWAY_TAG_IDENTIFIER) {
                return typeToLimit(tg.value)
            }
        }
        
        return nil
    }
    
    /* Extract maxspeed from tag in node */
    private func extractLimitFromNodeTag(n: node) -> Double? {
        // Ensure tag exist
        guard (n.subTag != nil) else {
            return nil
        }
        
        // Loop through all tags
        for tg in n.subTag! {
            if(tg.key == MAXSPEED_TAG_IDENTIFIER) {
                return Double(NSString(string: tg.value).doubleValue)
            }
        }
        
        return nil
    }
    
    /* Extract maxspeed from tag in way */
    private func extractLimitFromWayTag(w: way) -> Double? {
        // Ensure tag exist
        guard (w.subTag != nil) else {
            return nil
        }
        
        // Loop through all tags
        for tg in w.subTag! {
            if(tg.key == MAXSPEED_TAG_IDENTIFIER) {
                return Double(NSString(string: tg.value).doubleValue)
            }
        }
        
        return nil
    }
    
    /* Search nearest way cooresponding to given coordinates */
    /* Return: wayIndex, nodeIndex, isNext, wayDistance*/
    private func searchNearestWay(coord: coordinates) -> [Int] {
        var nearestWayIndex: Int = 0
        var wayDistance: Double! = 10000.0
        var finalNearestNodeIndex: Int = 0
        var finalNextNearest: Int = 1
        // Loop through all ways
        for wayIndex in 0..<data!.ways!.count {
            
            // Ensure subNode exist
            if (data!.ways![wayIndex].subNode != nil) {
                
                var nearestNodeIndex: Int = 0
                var nodeDistance: Double! = distanceTwoPoints(data!.ways![wayIndex].subNode![0].coord, coord2: coord)
                
                // Loop through all nodes in a single way
                for nodeIndex in 0..<data!.ways![wayIndex].subNode!.count {
                    let distance: Double! = distanceTwoPoints(data!.ways![wayIndex].subNode![nodeIndex].coord, coord2: coord)
                    // Get smallest distance
                    if(distance < nodeDistance) {
                        nearestNodeIndex = nodeIndex
                        nodeDistance = distance
                    }
                }
                
                /* Assuming pervious/next node are the second nearest node */
                // Line formed with pervious node
                let perviousLine: line = line(coord1: data!.ways![wayIndex].subNode![nearestNodeIndex].coord, coord2: data!.ways![wayIndex - 1].subNode![nearestNodeIndex].coord)
                
                let distancePervious: Double! = distanceLinePoint(perviousLine, coord: coord)
                
                // Line formed with next node
                let nextLine: line = line(coord1: data!.ways![wayIndex].subNode![nearestNodeIndex].coord, coord2: data!.ways![wayIndex + 1].subNode![nearestNodeIndex].coord)
                let distanceNext: Double! = distanceLinePoint(nextLine, coord: coord)
                
                let distance: Double! = (distancePervious > distanceNext ? distanceNext : distancePervious)
                // Get smallest distance
                if(distance < wayDistance) {
                    wayDistance = distance
                    nearestWayIndex = wayIndex
                    finalNearestNodeIndex = nearestNodeIndex
                    finalNextNearest = (distancePervious > distanceNext ? 1 : 0)
                }
                
            }
        }
        
        return [nearestWayIndex, finalNearestNodeIndex, finalNextNearest, Int(wayDistance)]
    }
    
    /* Calculate distance between two points */
    private func distanceTwoPoints(coord1: coordinates!, coord2: coordinates!) -> Double! {
        return (fabs(coord1.latitude - coord2.latitude) + fabs(coord1.longitude - coord2.longitude))
    }
    
    /* Calculate distance between line and point */
    private func distanceLinePoint(l: line, coord: coordinates) -> Double! {
        // (x,y) -> (lat,lon)
        let x1: Double! = l.coord1.latitude
        let x2: Double! = l.coord2.latitude
        let y1: Double! = l.coord1.longitude
        let y2: Double! = l.coord2.longitude
        let x0: Double! = coord.latitude
        let y0: Double! = coord.longitude
        
        let dx: Double! = x2 - x1
        let dy: Double! = y2 - y1
        
        // (y2-y1)x0 - (x2-x1)y0 + x2*y1 - y2*x1
        let numerator: Double! = dy*x0 - dx*y0 + x2*y1 - y2*x1
        // (y2-y1)^2 + (x2-x1)^2
        let denominator: Double! = pow(dy, 2.0) + pow(dx, 2.0)
        // |numerator| / sqrt(denominator)
        return (fabs(numerator)/sqrt(denominator))
    }
    
}
