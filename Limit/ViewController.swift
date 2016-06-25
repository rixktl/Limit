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
        print("speed:", speed)
        print("limit:", speedLimit)
        print("")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        speedModel.delegate = self
        speedModel.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

