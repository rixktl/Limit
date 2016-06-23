//
//  ViewController.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LocationManagerDelegate {
    
    let locationModel: LocationModel = LocationModel()
    
    func locationUpdate(data: LocationData) {
        data.printOut()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationModel.delegate = self
        locationModel.start()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

