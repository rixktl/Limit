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
    
    // Setting button clicked
    @IBAction func settingButtonClicked(sender: AnyObject) {
        speedModel.stop()
    }
    
    // Unit button clicked
    @IBAction func unitButtonClicked(sender: AnyObject) {
        speedModel.flipUnit()
    }
    
    // Updated by speedModel
    func updateSpeedInfo(speed: Double?, speedLimit: Double?, unit: Bool!) {
        print("speed:", speed)
        print("limit:", speedLimit)
        print("")
        
        if(speed != nil) {
            // Update speed label
            self.speedLabel.text = String(Int(round(speed!)))
        }
        
        // Update unit label
        if(unit!) {
            self.unitButton.setTitle(MPH_NAME, forState: UIControlState.Normal)
        } else {
            self.unitButton.setTitle(KPH_NAME, forState: UIControlState.Normal)
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
        //self.audioModel.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

