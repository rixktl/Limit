//
//  ViewController.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OpenStreetMapParserDelegate {
    
    let osmParser: OpenStreetMapParser = OpenStreetMapParser()
    
    func dataUpdate(data: OpenStreetMapData) {
        print("received")
        print(data.ways?.count)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        osmParser.delegate = self
        osmParser.request(coordinates(latitude: -122.047246, longitude: 37.324539))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

