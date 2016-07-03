//
//  OpenStreetMapData.swift
//  Limit
//
//  Created by Rix Lai on 6/23/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

struct OpenStreetMapData {
    var ways: [Way]?
}

struct Line {
    var coord1: Coordinates!
    var coord2: Coordinates!
    
    init(coord1: Coordinates!, coord2: Coordinates) {
        self.coord1 = coord1
        self.coord2 = coord2
    }
}

struct Coordinates {
    var latitude: Double!
    var longitude: Double!
    
    init(latitude: Double!, longitude: Double!) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct Tag {
    var key: String!
    var value: String!
    
    init(key: String!, value: String!) {
        self.key = key
        self.value = value
    }
}

struct Node {
    var id: String!
    var coord: Coordinates!
    var subTag: [Tag]?
    
    init(latitude: Double!, longitude: Double!) {
        self.coord = Coordinates(latitude: latitude, longitude: longitude)
    }
}

struct Way {
    var id: String!
    var subNode: [Node]?
    var subTag: [Tag]?
}
