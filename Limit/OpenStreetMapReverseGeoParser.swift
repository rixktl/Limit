//
//  OpenStreetMapReverseGeoParser.swift
//  Limit
//
//  Created by Rix Lai on 6/25/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/*
 * A parser for handling XML data from OpenStreetMap Nominatim.
 * It runs in async manner for both parsing and data fetching.
 */

internal protocol OpenStreetMapReverseGeoParserDelegate {
    func updateReverseGeoResult(data: OpenStreetMapReverseGeoData!)
}

/* Struct of result for reverse geo */
struct OpenStreetMapReverseGeoData {
    var id: String?
    var name: String?
    
    init() {
        self.id = nil
        self.name = nil
    }
    
    init(id: String?, name: String?) {
        self.id = id
        self.name = name
    }
}

public class OpenStreetMapReverseGeoParser: NSObject, NSXMLParserDelegate {
    
    private let PRE_URL: String! = "https://nominatim.openstreetmap.org/reverse?format=xml&lat="
    private let POST_URL: String! = "&zoom=17&addressdetails=1"
    private let COORDINATES_SEPARATION: String! = "&lon="
    private let RESULT_IDENTIFIER: String! = "result"
    private let OSM_ID_IDENTIFIER: String! = "osm_id"
    private let ROAD_NAME_IDENTIFIER: String! = "road"
    private let LOCK_TIME: Double! = 1.0
    
    internal var delegate: OpenStreetMapReverseGeoParserDelegate!
    private var parser: NSXMLParser!
    private var lock: Bool! = false
    private var foundRoadName: Bool! = false
    
    private var data: OpenStreetMapReverseGeoData! = OpenStreetMapReverseGeoData()

    /* Form an url according to coordinates */
    private func formUrl(coord: coordinates) -> String! {
        return String(coord.latitude) + COORDINATES_SEPARATION + String(coord.longitude)
    }
    
    /* Send an async request */
    private func asyncRequest(urlPath: String!) {
        //print(urlPath)
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
        
        // Create url
        let url: String! = PRE_URL + formUrl(coord) + POST_URL
        asyncRequest(url)
    }
    
    /* Called when parsing new element */
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if(elementName == RESULT_IDENTIFIER) {
            self.data.id = attributeDict[OSM_ID_IDENTIFIER]
        } else if(elementName == ROAD_NAME_IDENTIFIER) {
            self.foundRoadName = true
        }
    }
    
    /* Called when parsing character */
    public func parser(parser: NSXMLParser, foundCharacters string: String) {
        if(self.foundRoadName!) {
            self.data.name = string
            self.foundRoadName = false
        }
    }
    
    /* Called when parsing element ends */
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if(self.data.id != nil && self.data.name != nil) {
            self.delegate.updateReverseGeoResult(self.data!)
            
            // Clean up
            self.data.id = nil
            self.data.name = nil
        }
    }
    
    /* Called when error occurs in parser */
    public func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        // TODO: error handling
    }    
}
