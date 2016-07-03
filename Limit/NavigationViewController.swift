//
//  NavigationViewController.swift
//  Limit
//
//  Created by Rix Lai on 7/2/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    
    // Disable rotation
    override func shouldAutorotate() -> Bool {
        
        return false

        /*
        let currentViewController = self.topViewController!
        
        // ViewController
        if(currentViewController.isKindOfClass(UIViewController)) {
            return false
        } else {
            // Not ViewController
            return true
        }
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
