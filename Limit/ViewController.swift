//
//  ViewController.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OpenStreetMapModelDelegate {
    
    let osmModel: OpenStreetMapModel = OpenStreetMapModel()
    
    func limitUpdate(limit: Double?) {
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        osmModel.delegate = self
        osmModel.request(coordinates(latitude: -122.047246, longitude: 37.324539))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

