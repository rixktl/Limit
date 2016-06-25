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
    func updateSpeedLimit(speedLimit: Double?)
}

public class OpenStreetMapFinder {
    internal var data: OpenStreetMapData?
    internal var delegate: OpenStreetMapFinderDelegate!
    internal var offsetDegree: Double! = 15.0
    
    private let MAXSPEED_TAG_IDENTIFIER: String! = "maxspeed"
    private let HIGHWAY_TAG_IDENTIFIER: String! = "highway"
    private let REFERENCE_TAG_IDENTIFIER: String! = "ref"
    
    private let RESIDENTIAL_VALUE_IDENTIFIER: String! = "residential"
    private let SERVICE_VALUE_IDENTIFIER: String! = "service"
    private let SECONDARY_VALUE_IDENTIFIER: String! = "secondary"
    private let TERTIARY_VALUE_IDENTIFIER: String! = "tertiary"
    private let PRIMARY_VALUE_IDENTIFIER: String! = "primary"
    private let FREEWAY_VALUE_IDENTIFIER: String! = "freeway"
    private let MOTORWAY_VALUE_IDENTIFIER: String! = "motorway"
    private let TRUNK_VALUE_IDENTIFIER: String! = "trunk"
    
    /* Make a async search */
    internal func searchWithCoordinates(coord: coordinates!, direction: Double!, ref: String!) {
        let queue: NSOperationQueue = NSOperationQueue()
        
        queue.addOperationWithBlock { () -> Void in
            self.asyncSearch(coord, direction: direction, ref: ref)
        }
        
    }
    
    /* Search limit by coordinates */
    private func asyncSearch(coord: coordinates!, direction: Double!, ref: String!) {
        // Ensure data exist
        guard (data != nil && data!.ways != nil) else {
            // Failed to find speed limit
            delegate!.updateSpeedLimit(nil)
            return
        }
        
        if(ref != nil) {
        
            for wayIndex in 0..<data!.ways!.count {
            
                let maxspeed: Double! = extractLimitFromWayTagWithRef(data!.ways![wayIndex], ref: ref)
                if(maxspeed != nil) {
                    delegate.updateSpeedLimit(maxspeed)
                    return
                }
            }
        }
        
        // Find nearest way
        var wayResult: [Int] = searchNearestWay(coord, direction: direction)
        
        // Attempt to get maxspeed from way's tag
        var limit: Double? = extractLimitFromWayTag(data!.ways![wayResult[0]])
        
        if(limit != nil) {
            delegate.updateSpeedLimit(limit)
            //print("Way's Tag", wayResult[3])
            //print(data!.ways![wayResult[0]].id)
            //print(data!.ways![wayResult[0]].subNode![wayResult[1]])
            //print(data!.ways![wayResult[0]].subNode![ (wayResult[1] + wayResult[2]) ])
            return
        }
        
        // Attempt to get maxspeed from node's tag
        limit = extractLimitFromNodeTag(data!.ways![wayResult[0]].subNode![wayResult[1]])
        
        if(limit != nil) {
            delegate.updateSpeedLimit(limit)
            print("Node's Tag")
            return
        }
        
        // Attempt to get maxspeed from near node's tag
        let index: Int = (wayResult[2] == 1 ? wayResult[1] + 1 : wayResult[1] - 1)
        
        limit = extractLimitFromNodeTag(data!.ways![wayResult[0]].subNode![index])
        
        if(limit != nil) {
            delegate.updateSpeedLimit(limit)
            print("Near Node's Tag")
            return
        }
        
        // Attempt to get maxspeed from the rest node's tag
        for n in data!.ways![wayResult[0]].subNode! {
            limit = extractLimitFromNodeTag(n)
            if(limit != nil) {
                delegate.updateSpeedLimit(limit)
                print("All Node's Tag")
                return
            }
        }
        
        // Attempt to match speed limit with way's tag type
        limit = getLimitFromWayTagType(data!.ways![wayResult[0]])
        
        if(limit != nil) {
            delegate.updateSpeedLimit(limit)
            print("Way's Tag Type")
            return
        }
        
        // Attempt to match speed limit with node's tag type
        limit = getLimitFromNodeTagType(data!.ways![wayResult[0]].subNode![wayResult[1]])
        
        if(limit != nil) {
            delegate.updateSpeedLimit(limit)
            print("Node's Tag Type")
            return
        }
        
        // Attempt to match speed limit with near node's tag type
        limit = getLimitFromNodeTagType(data!.ways![wayResult[0]].subNode![index])
        
        if(limit != nil) {
            delegate.updateSpeedLimit(limit)
            print("Near Node's Tag Type")
            return
        }
        
        // Failed to find speed limit
        delegate.updateSpeedLimit(nil)
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
    
    private func extractLimitFromWayTagWithRef(w: way, ref: String!) -> Double? {
        // Ensure tag exist
        guard (w.subTag != nil) else {
            return nil
        }
        
        var maxspeed: Double?
        var hit: Bool! = false
        for tg in w.subTag! {
            if (tg.key == REFERENCE_TAG_IDENTIFIER && tg.value == ref) {
                hit = true
                if(maxspeed != nil) {
                    return maxspeed
                }
            }
            
            if(tg.key == MAXSPEED_TAG_IDENTIFIER) {
                maxspeed = Double(NSString(string: tg.value).doubleValue)
                if(hit == true) {
                    return maxspeed
                }
            }
        }
        
        return nil
    }
    
    /* Search nearest way cooresponding to given coordinates */
    /* Return: wayIndex, nodeIndex, isNext, wayDistance*/
    private func searchNearestWay(coord: coordinates!, direction: Double!) -> [Int] {
        var nearestWayIndex: Int = 0
        var wayDistance: Double! = 10000.0
        var finalNearestNodeIndex: Int = 0
        var finalNextNearest: Int = 1
        // Loop through all ways
        for wayIndex in 0..<data!.ways!.count {
            
            // Ensure subNode exist
            if (data!.ways![wayIndex].subNode != nil) {
                
                var nearestNodeIndex: Int = 0
                // Distance between first node and given coordinates
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
                
                var distancePervious: Double?
                var distanceNext: Double?
                
                if(nearestNodeIndex > 0) {
                    // Line formed with pervious node
                    let perviousLine: line = line(coord1: data!.ways![wayIndex].subNode![nearestNodeIndex].coord, coord2: data!.ways![wayIndex].subNode![nearestNodeIndex - 1].coord)
                    distancePervious = distanceLineSegmentPoint(perviousLine, coord: coord)
                }
                
                if(nearestNodeIndex + 1 < data!.ways![wayIndex].subNode!.count) {
                    // Line formed with next node
                    let nextLine: line = line(coord1: data!.ways![wayIndex].subNode![nearestNodeIndex].coord, coord2: data!.ways![wayIndex].subNode![nearestNodeIndex + 1].coord)
                    distanceNext = distanceLineSegmentPoint(nextLine, coord: coord)
                }
                
                var distance: Double! = 10000.0
                
                if(distancePervious != nil && distanceNext != nil) {
                    distance = (distancePervious > distanceNext ? distanceNext : distancePervious)
                    finalNextNearest = (distancePervious > distanceNext ? 1 : -1)
                } else if(distancePervious != nil) {
                    distance = distancePervious
                    finalNextNearest = -1
                } else if(distanceNext != nil) {
                    distance = distanceNext
                    finalNextNearest = 1
                }
                
                
                var l: line!
                if(finalNextNearest == 1) {
                    // Next
                    l = line(coord1: data!.ways![wayIndex].subNode![nearestNodeIndex].coord, coord2: data!.ways![wayIndex].subNode![nearestNodeIndex + 1].coord)
                } else {
                    // Previous
                    l = line(coord1: data!.ways![wayIndex].subNode![nearestNodeIndex - 1].coord, coord2: data!.ways![wayIndex].subNode![nearestNodeIndex].coord)
                }
                
                
                // Get smallest distance with acceptable direction
                if(distance < wayDistance && checkDirection(l, direction: direction)) {
                    wayDistance = distance
                    nearestWayIndex = wayIndex
                    finalNearestNodeIndex = nearestNodeIndex
                }
                
                
            }
        }

        return [nearestWayIndex, finalNearestNodeIndex, finalNextNearest, Int(wayDistance)]
    }
    
    private func checkDirection(l: line!, direction: Double!) -> Bool! {
        let dir: Double! = getDirection(l)
        return (fabs(dir - direction) <= offsetDegree)
    }
    
    private func getDirection(l: line!) -> Double! {
        let dlon: Double! = l.coord2.longitude - l.coord1.longitude
        let y: Double! = sin(dlon) * cos(l.coord2.latitude)
        let x: Double! = cos(l.coord1.latitude) * sin(l.coord2.latitude) - sin(l.coord1.latitude) * cos(l.coord2.latitude) * cos(dlon)
        var brng: Double! = atan2(y, x)
        brng = brng * 180 / M_PI
        brng = 360 - brng
        return brng
    }
    
    /* Calculate distance between two points */
    private func distanceTwoPoints(coord1: coordinates!, coord2: coordinates!) -> Double! {
        return sqrt(pow(coord1.latitude - coord2.latitude, 2) + pow(coord1.longitude - coord2.longitude, 2))
    }
    
    /* Calculate distance between line segment and point */
    private func distanceLineSegmentPoint(l: line, coord: coordinates) -> Double! {
        // (x,y) -> (lat,lon)
        let x1: Double! = l.coord1.latitude
        let x2: Double! = l.coord2.latitude
        let y1: Double! = l.coord1.longitude
        let y2: Double! = l.coord2.longitude
        let x0: Double! = coord.latitude
        let y0: Double! = coord.longitude
        
        // Check distance between two points that form the line segment
        let l2: Double! = distanceTwoPoints(l.coord1, coord2: l.coord2)
        // Two points are at the same location
        if(l2 == 0) {
            // Return distance between one point of line segment(same) and the given point
            return distanceTwoPoints(coord, coord2: l.coord1)
        }
        
        var t: Double! = (x0 - x1) * (x2 - x1) + (y0 - y1) * (y2 - y1) / l2
        t = max(0, min(1, t))
        
        let newPoint: coordinates! = coordinates( latitude: x1 + t*(x2 - x1),
                                                  longitude: y1 + t*(y2 - y1) )
        return sqrt( distanceTwoPoints(coord, coord2: newPoint) )
    }
    
}
