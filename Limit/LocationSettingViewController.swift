//
//  LocationSettingViewController.swift
//  Limit
//
//  Created by Rix Lai on 7/4/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit
import CoreLocation


class LocationSettingViewController: UIViewController, CLLocationManagerDelegate {
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    fileprivate let STORYBOARD_NAME: String = "Main"
    fileprivate let MAIN_VIEW_NAME: String = "MainView"
    
    // Light status bar content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    /* Called when setting button is clicked */
    @IBAction func SettingButtonClicked(_ sender: AnyObject) {
        // Open setting url
        UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    /* Called when permission status is changed */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.authorizedAlways:
            switchToView(MAIN_VIEW_NAME)
            break
        case CLAuthorizationStatus.notDetermined:
            break
        default:
            break
        }
    }
    
    /* Switch to other view */
    fileprivate func switchToView(_ name: String!) {
        let view: UIViewController = UIStoryboard.init(name: STORYBOARD_NAME, bundle: nil).instantiateViewController(withIdentifier: name)
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
