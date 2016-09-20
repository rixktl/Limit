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
    func updateReverseGeoResult(_ data: OpenStreetMapReverseGeoData!)
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

open class OpenStreetMapReverseGeoParser: NSObject, XMLParserDelegate {
    
    fileprivate let PRE_URL: String = "https://nominatim.openstreetmap.org/reverse?format=xml&lat="
    fileprivate let POST_URL: String = "&zoom=17&addressdetails=1"
    fileprivate let COORDINATES_SEPARATION: String = "&lon="
    fileprivate let RESULT_IDENTIFIER: String = "result"
    fileprivate let OSM_ID_IDENTIFIER: String = "osm_id"
    fileprivate let ROAD_NAME_IDENTIFIER: String = "road"
    fileprivate let LOCK_TIME: Double! = 1.0
    
    internal var delegate: OpenStreetMapReverseGeoParserDelegate!
    fileprivate var parser: XMLParser!
    fileprivate var lock: Bool! = false
    fileprivate var foundRoadName: Bool! = false
    
    fileprivate var data: OpenStreetMapReverseGeoData! = OpenStreetMapReverseGeoData()

    /* Form an url according to coordinates */
    fileprivate func formUrl(_ coord: Coordinates) -> String! {
        return String(coord.latitude) + COORDINATES_SEPARATION + String(coord.longitude)
    }
    
    /* Send an async request */
    fileprivate func asyncRequest(_ urlPath: String!) {
        //print(urlPath)
        let url = URL(string: urlPath)!
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            self.startParser(data, response: response, error: error as NSError?)
            return ()
        }) 
        
        task.resume()
    }
    
    /* Start XML parsing */
    fileprivate func startParser(_ data: Data?, response: URLResponse?, error: NSError?) {
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(LOCK_TIME * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: ({
            self.lock = false
        }))
        
        // Create url
        let url: String! = PRE_URL + formUrl(coord) + POST_URL
        asyncRequest(url)
    }
    
    /* Called when parsing new element */
    open func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if(elementName == RESULT_IDENTIFIER) {
            self.data.id = attributeDict[OSM_ID_IDENTIFIER]
        } else if(elementName == ROAD_NAME_IDENTIFIER) {
            self.foundRoadName = true
        }
    }
    
    /* Called when parsing character */
    open func parser(_ parser: XMLParser, foundCharacters string: String) {
        if(self.foundRoadName!) {
            self.data.name = string
            self.foundRoadName = false
        }
    }
    
    /* Called when parsing element ends */
    open func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if(self.data.id != nil && self.data.name != nil) {
            self.delegate.updateReverseGeoResult(self.data!)
            
            // Clean up
            self.data.id = nil
            self.data.name = nil
        }
    }
    
    /* Called when error occurs in parser */
    open func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // TODO: error handling
    }    
}
