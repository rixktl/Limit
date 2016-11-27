//
//  GoogleMapModel.swift
//  Limit
//
//  Created by Edward Lai on 11/26/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

internal protocol GoogleMapModelDelegate {
    
}

open class GoogleMapModel : NSObject, GoogleMapModelDelegate {
    
    internal var delegate: GoogleMapModelDelegate?
    
    fileprivate let GOOGLE_SPEEDLIMIT_URL = "https://roads.googleapis.com/v1/speedLimits?"
    fileprivate let GOOGLE_API_KEY = "AIzaSyAgSFT1KuEnJLBuzhPyGguYWXMnXEyYhBg"
    fileprivate let GOOGLE_COORDINATES_SEPARATOR = "|"
    fileprivate let COORDINATE_SEPARATOR = ","
    fileprivate let LATITUDE_OFFSET: Double! = 0.01
    fileprivate let LONGITUDE_OFFSET: Double! = 0.01
    fileprivate let LOCK_TIME: Double! = 2.5
    
    fileprivate var coord: Coordinates?
    fileprivate var lock: Bool! = false
    
    override public init() {
        super.init()
    }
    
    /* Form parameters according to coordinates */
    fileprivate func formParameters(_ minLat: Double!, _ maxLat: Double!,
                             _ minLon: Double!, _ maxLon: Double!) -> String! {
        return String(minLon) + COORDINATE_SEPARATOR +
            String(minLat) + GOOGLE_COORDINATES_SEPARATOR + String(maxLon) +
            COORDINATE_SEPARATOR as String + String(maxLat)
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
        let minLat: Double! = coord.latitude - LATITUDE_OFFSET
        let maxLat: Double! = coord.latitude + LATITUDE_OFFSET
        let minLon: Double! = coord.longitude - LONGITUDE_OFFSET
        let maxLon: Double! = coord.longitude + LONGITUDE_OFFSET
        
        // Create url
        let url: String! = GOOGLE_SPEEDLIMIT_URL as String + "path=" as String
         + formParameters(minLat, maxLat, minLon, maxLon)
         + "&key=" as String + GOOGLE_API_KEY as String

        asyncRequest(url)
    }
    
    /* Send an async request */
    fileprivate func asyncRequest(_ urlPath: String!) {
        let urlStr: NSString = NSString(string: urlPath)
        let urlConverted: String? = urlStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: urlConverted!)
        print(urlStr)
        let session = URLSession.shared

        let task = session.dataTask(with: url!,
            completionHandler: { (data, response, error) -> Void in
            self.startParser(data, response: response, error: error as NSError?)
            return ()
        })

        task.resume()
    }

    /* Start XML parsing */
    fileprivate func startParser(_ data: Data?, response: URLResponse?,
                                 error: NSError?) {
      /*
        guard (data != nil && (response as! HTTPURLResponse).statusCode == 200) else {
            // TODO: error handling
            print("error:")
            print(String(describing: error))
            return
        }
 */
        print("^")
        print(data)
    }
    
    
}
