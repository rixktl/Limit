//
//  OpenStreetMapParser.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/*
 * A parser for handling XML data.
 * It runs in async manner for both parsing and data fetching.
 */

internal protocol OpenStreetMapParserDelegate {
    func dataUpdate(data: OpenStreetMapData)
}

public class OpenStreetMapParser: NSObject, NSXMLParserDelegate {
    
    /* 
     * Target XML is constructed based on tags, nodes and ways.
     * There are nodes in the first part and ways in second part.
     */
    
    internal var delegate: OpenStreetMapParserDelegate!
    internal var offsetLatitude: Double!
    internal var offsetLongitude: Double!
    
    private let PRE_URL: String! = "https://www.overpass-api.de/api/xapi?*[maxspeed=*][bbox="
    private let POST_URL: String! = "]"
    private let COORDINATES_SEPARATION: String! = ","
    
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
    private var tmpNode: [String: node]!
    private var result: OpenStreetMapData!
    private var isNode: Bool!
    private var parser: NSXMLParser!
    
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
        return String(minLat) + COORDINATES_SEPARATION + String(minLon) + COORDINATES_SEPARATION + String(maxLat) + COORDINATES_SEPARATION + String(maxLon)
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
    internal func request(coord: coordinates!) {
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
                let newTag: tag = tag(key: attributeDict[KEY_IDENTIFIER], value: attributeDict[VALUE_IDENTIFIER])
                // Determines type of father struct
                if(isNode!) {
                    // Initialize if not exist
                    if(tmpNode[nodeIndex]!.subTag == nil) {
                        tmpNode[nodeIndex]!.subTag = [tag]()
                    }
                    // Add new tag
                    tmpNode[nodeIndex]!.subTag!.append(newTag)
                } else {
                    // Initialize if not exist
                    if(result!.ways![wayIndex-1].subTag == nil) {
                        result!.ways![wayIndex-1].subTag = [tag]()
                    }
                    // Add new tag
                    result!.ways![wayIndex-1].subTag!.append(newTag)
                }
            
            case NODE_IDENTIFIER:
                isNode = true
                let newNode: node = node(latitude: Double(attributeDict[LATITUDE_IDENTIFIER]!), longitude: Double(attributeDict[LONGITUDE_IDENTIFIER]!))
                // Add new node
                tmpNode[attributeDict[ID_IDENTIFIER]!] = newNode
                nodeIndex = attributeDict[ID_IDENTIFIER]
            
            case WAY_IDENTIFIER:
                // Initialize if not exist
                if(wayIndex == 0) {
                    result!.ways = [way]()
                }
                isNode = false
                let newWay: way = way()
                // Add new way
                result!.ways!.append(newWay)
                wayIndex += 1
            
            case SUB_NODE_IDENTIFIER:
                // Initialize if not exist
                if(result!.ways![wayIndex-1].subNode == nil) {
                    result!.ways![wayIndex-1].subNode = [node]()
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
            delegate!.dataUpdate(result!)
        }
    }
    
    /* Called when error occurs in parser */
    public func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        // TODO: error handling
    }
}
