//
//  OpenStreetMapParser.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/*
 * A parser for handling XML data from OpenStreetMap XAPI.
 * It runs in async manner for both parsing and data fetching.
 */

internal protocol OpenStreetMapParserDelegate {
    func updateData(data: OpenStreetMapData!)
}

public class OpenStreetMapParser: NSObject, NSXMLParserDelegate {
    
    /* 
     * Target XML is constructed based on tags, nodes and ways.
     * There are nodes in the first part and ways in second part.
     */
    
    internal var delegate: OpenStreetMapParserDelegate!
    internal var offsetLatitude: Double!
    internal var offsetLongitude: Double!
    internal var coord: Coordinates?
    
    private let PRE_URL: String! = "https://www.overpass-api.de/api/xapi?way[maxspeed=*][bbox="
    private let POST_URL: String! = "]"
    private let COORDINATES_SEPARATION: String! = ","
    private let LOCK_TIME: Double! = 2.5
    
    private let OSM_IDENTIFIER: String! = "osm"
    private let TAG_IDENTIFIER: String! = "tag"
    private let NODE_IDENTIFIER: String! = "node"
    private let WAY_IDENTIFIER: String! = "way"
    private let SUB_NODE_IDENTIFIER: String! = "nd"
    private let KEY_IDENTIFIER: String! = "k"
    private let VALUE_IDENTIFIER: String! = "v"
    private let REFERENCE_IDENTIFIER: String! = "ref"
    private let ID_IDENTIFIER: String! = "id"
    private let LATITUDE_IDENTIFIER: String! = "lat"
    private let LONGITUDE_IDENTIFIER: String! = "lon"
    
    private var wayIndex: Int
    private var nodeIndex: String!
    private var tmpNode: [String: Node]!
    private var result: OpenStreetMapData!
    private var isNode: Bool!
    private var parser: NSXMLParser!
    private var lock: Bool! = false
    
    override public init() {
        wayIndex = 0
        nodeIndex = ""
        tmpNode = [:]
        result = OpenStreetMapData()
        isNode = true
        parser = NSXMLParser()
        // Default values
        offsetLatitude = 0.01
        offsetLongitude = 0.01
        
        super.init()
    }
    
    /* Form an url according to coordinates */
    private func formUrl(minLat: Double!, _ maxLat: Double!, _ minLon: Double!, _ maxLon: Double!) -> String! {
        return String(minLon) + COORDINATES_SEPARATION + String(minLat) + COORDINATES_SEPARATION + String(maxLon) + COORDINATES_SEPARATION + String(maxLat)
    }
    
    /* Send an async request */
    private func asyncRequest(urlPath: String!) {
        let url = NSURL(string: urlPath)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url) { data, response, error in
            self.startParser(data, response: response, error: error)
        }
        
        task.resume()
    }
    
    /* Start XML parsing */
    private func startParser(data: NSData?, response: NSURLResponse?, error: NSError?) {
        guard (data != nil) else {
            // TODO: error handling
            print("error:")
            print(String(error))
            return
        }
        parser = NSXMLParser(data: data!)
        parser.delegate = self
        parser.parse()
    }
    
    /* Request for new data corresponding to coordinates */
    internal func request(coord: Coordinates!) {
        // Ensure unlocked
        guard (lock == false) else {
            return
        }
        
        // Lock
        lock = true
        
        // Delay unlock
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(LOCK_TIME * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), ({
            self.lock = false
        }))
        
        // Set coordinates
        self.coord = coord
        
        // Calculate coordinates for bounded box
        let minLat: Double! = coord.latitude - offsetLatitude
        let maxLat: Double! = coord.latitude + offsetLatitude
        let minLon: Double! = coord.longitude - offsetLongitude
        let maxLon: Double! = coord.longitude + offsetLongitude
        
        // Create url
        let url: String! = PRE_URL + formUrl(minLat, maxLat, minLon, maxLon) + POST_URL
        asyncRequest(url)
    }
    
    /* Called when parsing new element */
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        switch elementName {
            case TAG_IDENTIFIER:
                let newTag: Tag = Tag(key: attributeDict[KEY_IDENTIFIER], value: attributeDict[VALUE_IDENTIFIER])
                // Determines type of father struct
                if(isNode!) {
                    // Initialize if not exist
                    if(tmpNode[nodeIndex]!.subTag == nil) {
                        tmpNode[nodeIndex]!.subTag = [Tag]()
                    }
                    // Add new tag
                    tmpNode[nodeIndex]!.subTag!.append(newTag)
                } else {
                    // Initialize if not exist
                    if(result!.ways![wayIndex-1].subTag == nil) {
                        result!.ways![wayIndex-1].subTag = [Tag]()
                    }
                    // Add new tag
                    result!.ways![wayIndex-1].subTag!.append(newTag)
                }
            
            case NODE_IDENTIFIER:
                isNode = true
                var newNode: Node = Node(latitude: Double(attributeDict[LATITUDE_IDENTIFIER]!), longitude: Double(attributeDict[LONGITUDE_IDENTIFIER]!))
                newNode.id = attributeDict[ID_IDENTIFIER]
                // Add new node
                tmpNode[attributeDict[ID_IDENTIFIER]!] = newNode
                nodeIndex = attributeDict[ID_IDENTIFIER]
            
            case WAY_IDENTIFIER:
                // Initialize if not exist
                if(wayIndex == 0) {
                    result!.ways = [Way]()
                }
                isNode = false
                var newWay: Way = Way()
                newWay.id = attributeDict[ID_IDENTIFIER]
                // Add new way
                result!.ways!.append(newWay)
                wayIndex += 1
            
            case SUB_NODE_IDENTIFIER:
                // Initialize if not exist
                if(result!.ways![wayIndex-1].subNode == nil) {
                    result!.ways![wayIndex-1].subNode = [Node]()
                }
                // Reference to node in way
                result!.ways![wayIndex-1].subNode!.append(tmpNode[attributeDict[REFERENCE_IDENTIFIER]!]!)
            
            default:
                break
        }
    }
    
    /* Called when parsing element ends */
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // Update result when reaching end of file
        if(elementName == OSM_IDENTIFIER) {
            delegate!.updateData(result!)
        }
    }
    
    /* Called when error occurs in parser */
    public func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        // TODO: error handling
    }
}
