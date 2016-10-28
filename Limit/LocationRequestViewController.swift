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
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    fileprivate let STORYBOARD_NAME: String = "Main"
    fileprivate let MAIN_VIEW_NAME: String = "MainView"
    fileprivate let LOCATION_SETTING_VIEW_NAME: String = "LocationSettingView"
    fileprivate var clicked: Bool! = false
    
    /* Background is white, no needed
    // Light status bar content
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    */
    
    /* Called when enable button is clicked */
    @IBAction func enableButtonClicked(_ sender: AnyObject) {
        clicked = true
        // Check permission before requesting
        switch CLLocationManager.authorizationStatus() {
            case CLAuthorizationStatus.authorizedAlways:
                switchToView(MAIN_VIEW_NAME)
            case CLAuthorizationStatus.denied:
                switchToView(LOCATION_SETTING_VIEW_NAME)
            default:
                locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    /* Called when permission status is changed */
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        // Ensure clicked
        guard (clicked == true) else {
            return
        }
        
        switch status {
            case CLAuthorizationStatus.authorizedAlways:
                switchToView(MAIN_VIEW_NAME)
                break
            case CLAuthorizationStatus.notDetermined:
                break
            default:
                switchToView(LOCATION_SETTING_VIEW_NAME)
                break
        }
    }
    
    /* Switch to other view */
    fileprivate func switchToView(_ name: String!) {
        let view: UIViewController = UIStoryboard.init(name: STORYBOARD_NAME,
                     bundle: nil).instantiateViewController(withIdentifier: name)
        self.present(view, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
