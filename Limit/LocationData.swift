//
//  LocationData.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

struct LocationData {
    
    var speed: Double?
    var direction: Double?
    var ref: String?
    var latitude: Double?
    var longitude: Double?
    var state: String?
    
    init(speed: Double?, direction: Double?, ref: String?, latitude: Double?, longitude: Double?, state: String?) {
        self.speed = speed
        self.direction = direction
        self.ref = ref
        self.latitude = latitude
        self.longitude = longitude
        self.state = state
    }
    
    
}
