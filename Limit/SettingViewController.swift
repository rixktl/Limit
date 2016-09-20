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
    fileprivate let settingModel: SettingModel = SettingModel()
    fileprivate let MPH_NAME: String = "M P H"
    fileprivate let KPH_NAME: String = "K P H"
    fileprivate let ON_NAME: String = "On"
    fileprivate let OFF_NAME: String = "Off"
    
    // Light status bar content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // Disable rotation
    override var shouldAutorotate : Bool {
        return false
    }
    
    /* Called when unit button is clicked */
    @IBAction func unitButtonClicked(_ sender: AnyObject) {
        settingModel.flipUnit()
    }
    
    /* Called when accuracy button is clicked */
    @IBAction func accuracyButtonClicked(_ sender: AnyObject) {
        settingModel.flipAccuracy()
    }
    
    /* Called when done button is clicked */
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        // Go back to main view
        self.dismiss(animated: true, completion: nil)
    }
    
    /* Updated by setting model */
    internal func updateSettings(_ settings: Settings!) {
        // Update unit
        if(settings.isMPH!) {
            DispatchQueue.main.async {
                self.unitButton.setTitle(self.MPH_NAME, for: UIControlState())
            }
        } else {
            DispatchQueue.main.async {
                self.unitButton.setTitle(self.KPH_NAME, for: UIControlState())
            }
        }
        
        // Update accuracy
        if(settings.isExact!) {
            DispatchQueue.main.async {
                self.accuracyButton.setTitle(self.ON_NAME, for: UIControlState())
            }
        } else {
            DispatchQueue.main.async {
                self.accuracyButton.setTitle(self.OFF_NAME, for: UIControlState())
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
