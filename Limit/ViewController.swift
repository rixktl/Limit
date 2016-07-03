//
//  ViewController.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SpeedModelDelegate {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    internal let speedModel: SpeedModel = SpeedModel()
    private let audioModel: AudioModel = AudioModel()
    private let MPH_NAME: String! = "M P H"
    private let KPH_NAME: String! = "K P H"
    private let GREEN_COLOR = UIColor.init(red: 0.0/255.0, green: 180.0/255.0, blue: 81.0/255.0, alpha: 1)
    private let RED_COLOR = UIColor.init(red: 222.0/255.0, green: 78.0/255.0, blue: 90.0/255.0, alpha: 1)
    private let BLACK_COLOR = UIColor.blackColor()
    
    private var supposedColor: UIColor?
    private var speed: Double?
    
    /* Initialize */
    convenience init() {
        self.init()
        // Cannot set delegate for speed model here
        // TODO: research on view controller
    }
    
    // Handle rotation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            // Get orientation
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            
            switch orientation {
                // Landscape
                case .LandscapeLeft, .LandscapeRight:
                    self.settingButton.hidden = true
                default:
                    // Non-Landscape
                    self.settingButton.hidden = false
            }
            
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                // Rotation completed
        })
        
        // Transition for view
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    // Light status bar content
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // Setting button clicked
    @IBAction func settingButtonClicked(sender: AnyObject) {
        speedModel.stop()
    }
    
    // Unit button clicked
    @IBAction func unitButtonClicked(sender: AnyObject) {
        speedModel.flipUnit()
    }
    
    // Updated by speedModel
    func updateSpeedInfo(speed: Double!, unit: Bool!, status: Status) {
        
        self.speed = speed
        // Update speed label with rounded number
        dispatch_async(dispatch_get_main_queue()) {
            self.speedLabel.text = String(Int(round(self.speed!)))
        }
        
        // Update unit label
        if(unit!) {
            dispatch_async(dispatch_get_main_queue()) {
                self.unitButton.setTitle(self.MPH_NAME, forState: UIControlState.Normal)
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.unitButton.setTitle(self.KPH_NAME, forState: UIControlState.Normal)
            }
        }
        
        // Update background according to status code
        switch status {
            case Status.Alert:
                audioModel.play()
                supposedColor = RED_COLOR
            case Status.Normal:
                supposedColor = GREEN_COLOR
            case Status.Rest:
                supposedColor = BLACK_COLOR
        }
        
        if(self.view.backgroundColor != supposedColor) {
            dispatch_async(dispatch_get_main_queue()) {
                self.view.backgroundColor = self.supposedColor
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Prepare speed model
        speedModel.delegate = self
        speedModel.start()
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

