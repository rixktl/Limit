//
//  OpenStreetMapData.swift
//  Limit
//
//  Created by Rix Lai on 6/23/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

struct OpenStreetMapData {
    var ways: [way]?
}

struct coordinates {
    var latitude: Double!
    var longitude: Double!
    
    init(latitude: Double!, longitude: Double!) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct tag {
    var key: String!
    var value: String!
    
    init(key: String!, value: String!) {
        self.key = key
        self.value = value
    }
}

struct node {
    var coord: coordinates!
    var subTag: [tag]?
    
    init(latitude: Double!, longitude: Double!) {
        self.coord = coordinates(latitude: latitude, longitude: longitude)
    }
}

struct way {
    var subNode: [node]?
    var subTag: [tag]?
}
