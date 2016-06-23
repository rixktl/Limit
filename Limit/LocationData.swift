//
//  LocationData.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

public struct LocationData {
    
    private var speed: Double?
    private var latitude: Double?
    private var longitude: Double?
    private var state: String?
    
    public init(speed: Double?, latitude: Double?, longitude: Double?, state: String?) {
        self.speed = speed
        self.latitude = latitude
        self.longitude = longitude
        self.state = state
    }
    
    public func printOut() {
        print("speed:", speed)
        print("latitude:", latitude)
        print("longitude:", longitude)
        print("state:", state)
        print("")
    }
    
}
