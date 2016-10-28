//
//  LocationData.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

struct LocationData {
    
    var coord: Coordinates?
    var state: String?
    var thoroughfare: String?
    var speed: Double?
    var direction: Double?
    
    init(speed: Double?, direction: Double?, thoroughfare: String?,
         coord: Coordinates?, state: String?) {
        self.coord = coord
        self.state = state
        self.thoroughfare = thoroughfare
        self.speed = speed
        self.direction = direction
    }
    
    
}
