//
//  SettingViewController.swift
//  Limit
//
//  Created by Rix Lai on 7/3/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, SettingModelDelegate {
    
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var accuracyButton: UIButton!
    private let settingModel: SettingModel = SettingModel()
    private let MPH_NAME: String! = "M P H"
    private let KPH_NAME: String! = "K P H"
    private let ON_NAME: String! = "On"
    private let OFF_NAME: String! = "Off"
    
    // Light status bar content
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // Disable rotation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    /* Called when unit button is clicked */
    @IBAction func unitButtonClicked(sender: AnyObject) {
        settingModel.flipUnit()
    }
    
    /* Called when accuracy button is clicked */
    @IBAction func accuracyButtonClicked(sender: AnyObject) {
        settingModel.flipAccuracy()
    }
    
    /* Called when done button is clicked */
    @IBAction func doneButtonClicked(sender: AnyObject) {
        // Go back to main view
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Updated by setting model */
    internal func updateSettings(settings: Settings!) {
        // Update unit
        if(settings.isMPH!) {
            dispatch_async(dispatch_get_main_queue()) {
                self.unitButton.setTitle(self.MPH_NAME, forState: UIControlState.Normal)
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.unitButton.setTitle(self.KPH_NAME, forState: UIControlState.Normal)
            }
        }
        
        // Update accuracy
        if(settings.isExact!) {
            dispatch_async(dispatch_get_main_queue()) {
                self.accuracyButton.setTitle(self.ON_NAME, forState: UIControlState.Normal)
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.accuracyButton.setTitle(self.OFF_NAME, forState: UIControlState.Normal)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        settingModel.delegate = self
        // Check settings
        settingModel.didChangeSetting()
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
