//
//  SpeedModel.swift
//  Limit
//
//  Created by Rix Lai on 6/24/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

internal protocol SpeedModelDelegate {
    func updateSpeedInfo(speed: Double?, speedLimit: Double?)
}

public class SpeedModel: NSObject, OpenStreetMapModelDelegate, LocationManagerDelegate {
    
    private let osmModel: OpenStreetMapModel = OpenStreetMapModel()
    private let locManager: LocationModel = LocationModel()
    
    internal var delegate: SpeedModelDelegate!
    private var speed: Double?
    private var speedLimit: Double?
    
    override init() {
        super.init()
        osmModel.delegate = self
        locManager.delegate = self
    }
    
    public func start() {
        locManager.start()
    }
    
    public func stop() {
        locManager.stop()
    }
    
    internal func updateSpeedLimit(speedLimit: Double?) {
        self.speedLimit = speedLimit
        delegate.updateSpeedInfo(self.speed, speedLimit: self.speedLimit)
    }
    
    internal func locationUpdate(data: LocationData) {
        self.speed = data.speed
        print(data.latitude)
        print(data.longitude)
        print(data.direction)
        osmModel.newCoordinates(coordinates(latitude: data.latitude, longitude: data.longitude), direction: data.direction, ref: data.ref)
        delegate.updateSpeedInfo(self.speed, speedLimit: self.speedLimit)
    }
}
