//
//  LocationRequestViewController.swift
//  Limit
//
//  Created by Rix Lai on 7/4/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit
import CoreLocation

class LocationRequestViewController: UIViewController, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private let STORYBOARD_NAME: String! = "Main"
    private let MAIN_VIEW_NAME: String! = "MainView"
    private let LOCATION_SETTING_VIEW_NAME: String! = "LocationSettingView"
    private var clicked: Bool! = false
    
    /* Background is white, no needed
    // Light status bar content
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    */
    
    /* Called when enable button is clicked */
    @IBAction func enableButtonClicked(sender: AnyObject) {
        clicked = true
        // Check permission before requesting
        switch CLLocationManager.authorizationStatus() {
            case CLAuthorizationStatus.AuthorizedAlways:
                switchToView(MAIN_VIEW_NAME)
            case CLAuthorizationStatus.Denied:
                switchToView(LOCATION_SETTING_VIEW_NAME)
            default:
                locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    /* Called when permission status is changed */
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // Ensure clicked
        guard (clicked == true) else {
            return
        }
        
        switch status {
            case CLAuthorizationStatus.AuthorizedAlways:
                switchToView(MAIN_VIEW_NAME)
                break
            case CLAuthorizationStatus.NotDetermined:
                break
            default:
                switchToView(LOCATION_SETTING_VIEW_NAME)
                break
        }
    }
    
    /* Switch to other view */
    private func switchToView(name: String!) {
        let view: UIViewController = UIStoryboard.init(name: STORYBOARD_NAME, bundle: nil).instantiateViewControllerWithIdentifier(name)
        self.presentViewController(view, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Set up location manger
        locationManager.delegate = self
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
