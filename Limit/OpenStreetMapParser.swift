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
    func updateData(_ data: OpenStreetMapData!)
}

open class OpenStreetMapParser: NSObject, XMLParserDelegate {
    
    /* 
     * Target XML is constructed based on tags, nodes and ways.
     * There are nodes in the first part and ways in second part.
     */
    
    internal var delegate: OpenStreetMapParserDelegate!
    internal var offsetLatitude: Double!
    internal var offsetLongitude: Double!
    internal var coord: Coordinates?
    
    fileprivate let PRE_URL: String = "https://www.overpass-api.de/api/xapi?way[maxspeed=*][bbox="
    fileprivate let POST_URL: String = "]"
    fileprivate let COORDINATES_SEPARATION: String = ","
    fileprivate let LOCK_TIME: Double! = 2.5
    
    fileprivate let OSM_IDENTIFIER: String = "osm"
    fileprivate let TAG_IDENTIFIER: String = "tag"
    fileprivate let NODE_IDENTIFIER: String = "node"
    fileprivate let WAY_IDENTIFIER: String = "way"
    fileprivate let SUB_NODE_IDENTIFIER: String = "nd"
    fileprivate let KEY_IDENTIFIER: String = "k"
    fileprivate let VALUE_IDENTIFIER: String = "v"
    fileprivate let REFERENCE_IDENTIFIER: String = "ref"
    fileprivate let ID_IDENTIFIER: String = "id"
    fileprivate let LATITUDE_IDENTIFIER: String = "lat"
    fileprivate let LONGITUDE_IDENTIFIER: String = "lon"
    
    fileprivate var wayIndex: Int
    fileprivate var nodeIndex: String!
    fileprivate var tmpNode: [String: Node]!
    fileprivate var result: OpenStreetMapData!
    fileprivate var isNode: Bool!
    fileprivate var parser: XMLParser!
    fileprivate var lock: Bool! = false
    
    override public init() {
        wayIndex = 0
        nodeIndex = ""
        tmpNode = [:]
        result = OpenStreetMapData()
        isNode = true
        parser = XMLParser()
        // Default values
        offsetLatitude = 0.01
        offsetLongitude = 0.01
        
        super.init()
    }
    
    /* Form an url according to coordinates */
    fileprivate func formUrl(_ minLat: Double!, _ maxLat: Double!,
                             _ minLon: Double!, _ maxLon: Double!) -> String! {
        return String(minLon) + COORDINATES_SEPARATION as String +
         String(minLat) + COORDINATES_SEPARATION as String + String(maxLon) +
         COORDINATES_SEPARATION as String + String(maxLat)
    }
    
    /* Send an async request */
    fileprivate func asyncRequest(_ urlPath: String!) {
        let url = URL(string: urlPath)!
        let session = URLSession.shared
        
        let task = session.dataTask(with: url,
                        completionHandler: { (data, response, error) -> Void in
            self.startParser(data, response: response, error: error as NSError?)
            return ()
        }) 
        
        task.resume()
    }
    
    /* Start XML parsing */
    fileprivate func startParser(_ data: Data?, response: URLResponse?,
                                 error: NSError?) {
        guard (data != nil) else {
            // TODO: error handling
            print("error:")
            print(String(describing: error))
            return
        }
        parser = XMLParser(data: data!)
        parser.delegate = self
        parser.parse()
    }
    
    /* Request for new data corresponding to coordinates */
    internal func request(_ coord: Coordinates!) {
        // Ensure unlocked
        guard (lock == false) else {
            return
        }
        
        // Lock
        lock = true
        
        // Delay unlock
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() +
         Double(Int64(LOCK_TIME * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                                      execute: ({
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
        let url: String! = PRE_URL as String +
         formUrl(minLat, maxLat, minLon, maxLon) + POST_URL as String
        asyncRequest(url)
    }
    
    /* Called when parsing new element */
    open func parser(_ parser: XMLParser,
                     didStartElement elementName: String,
                     namespaceURI: String?, qualifiedName qName: String?,
                     attributes attributeDict: [String : String]) {
        
        switch elementName {
            case TAG_IDENTIFIER:
                let newTag: Tag = Tag(key: attributeDict[KEY_IDENTIFIER],
                                      value: attributeDict[VALUE_IDENTIFIER])
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
                var newNode: Node = Node(latitude: Double(attributeDict[LATITUDE_IDENTIFIER]!),
                                         longitude: Double(attributeDict[LONGITUDE_IDENTIFIER]!))
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
    open func parser(_ parser: XMLParser, didEndElement elementName: String,
                     namespaceURI: String?, qualifiedName qName: String?) {
        // Update result when reaching end of file
        if(elementName == OSM_IDENTIFIER) {
            delegate!.updateData(result!)
        }
    }
    
    /* Called when error occurs in parser */
    open func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // TODO: error handling
    }
}
