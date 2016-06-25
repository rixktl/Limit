//
//  ViewController.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SpeedModelDelegate {
    
    
    let speedModel: SpeedModel = SpeedModel()
    
    func updateSpeedInfo(speed: Double?, speedLimit: Double?) {
        print("Speed: ", speed)
        print("SpeedLimit: ", speedLimit)
        print("")
    }
 
    
    let osmModel: OpenStreetMapModel = OpenStreetMapModel()
    
    func updateSpeedLimit(speedLimit: Double?) {
        print(speedLimit)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        speedModel.delegate = self
        speedModel.start()
        //osmModel.delegate = self
        //osmModel.newCoordinates(coordinates(latitude: 37.334820000000001, longitude: -122.0370759))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

