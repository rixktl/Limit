//
//  ViewController.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, SpeedModelDelegate {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    internal let speedModel: SpeedModel = SpeedModel()
    fileprivate var loadingModel: LoadingModel? = nil
    fileprivate let audioModel: AudioModel = AudioModel()
    fileprivate let LOAD_VIEW_ID: String = "LoadingView"
    fileprivate let MPH_NAME: String = "M P H"
    fileprivate let KPH_NAME: String = "K P H"
    fileprivate let GREEN_COLOR = UIColor.init(red: 0.0/255.0, green: 180.0/255.0,
                                                   blue: 81.0/255.0, alpha: 1)
    fileprivate let RED_COLOR = UIColor.init(red: 222.0/255.0, green: 78.0/255.0,
                                                   blue: 90.0/255.0, alpha: 1)
    fileprivate let BLACK_COLOR = UIColor.black
    
    fileprivate var supposedColor: UIColor?
    fileprivate var speed: Double?
    
    /* Initialize */
    convenience init() {
        self.init()
        // Cannot set delegate for speed model here
        // TODO: research on view controller
    }
    
    /* Deinitialize*/
    deinit {
        NotificationCenter.default.removeObserver(self,
                  name: NSNotification.Name(rawValue: "DID_RECEIVE_MESSAGE"),
                  object: nil)
    }
    
    // Handle rotation
    override func viewWillTransition(to size: CGSize,
                     with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: {
         (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            // Get orientation
            let orientation = UIApplication.shared.statusBarOrientation
            
            switch orientation {
                // Landscape
                case .landscapeLeft, .landscapeRight:
                    self.settingButton.isHidden = true
                default:
                    // Non-Landscape
                    self.settingButton.isHidden = false
            }
            
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                // Rotation completed
        })
        
        // Transition for view
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // Light status bar content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    /* Setting button clicked */
    @IBAction func settingButtonClicked(_ sender: AnyObject) {
        speedModel.stop()
        loadingModel!.stop()
    }
    
    /* Unit button clicked */
    @IBAction func unitButtonClicked(_ sender: AnyObject) {
        speedModel.flipUnit()
    }
    
    /* Updated by speedModel */
    func updateSpeedInfo(_ speed: Double!, speedLimit: Double?, unit: Bool!,
                         status: Status) {
        
        // Disabling loading view for a while
        DispatchQueue.main.async {
            self.loadingModel?.removeView()
            self.loadingModel?.keepAlive()
        }
        
        // Update speed label with rounded number
        self.speed = speed
        DispatchQueue.main.async {
            self.speedLabel.text = String(Int(round(self.speed!)))
        }
        
        // Update unit label
        if(unit!) {
            DispatchQueue.main.async {
                self.unitButton.setTitle(self.MPH_NAME, for: UIControlState())
            }
        } else {
            DispatchQueue.main.async {
                self.unitButton.setTitle(self.KPH_NAME, for: UIControlState())
            }
        }
        
        // Update background according to status code
        switch status {
            case Status.alert:
                audioModel.play()
                supposedColor = RED_COLOR
            case Status.normal:
                supposedColor = GREEN_COLOR
            case Status.rest:
                supposedColor = BLACK_COLOR
        }
        
        // Update background only if needed
        if(self.view.backgroundColor != supposedColor) {
            DispatchQueue.main.async {
                self.view.backgroundColor = self.supposedColor
            }
        }
    }
    
    /* Receive message from Apple Watch */
    func watchModel(_ notification: Notification) {
        // Check if it is pre-message
        if((notification as NSNotification).userInfo!["INFO"] != nil &&
         (notification as NSNotification).userInfo!["INFO"] as! String == "NONE") {
            // Shut down unnessary job
            speedModel.stop()
            loadingModel!.stop()
            // Reply Apple Watch
            WCSession.default().sendMessage(["INFO":"CONFIRMED"],
                                            replyHandler: nil,
                                            errorHandler: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen to message from Apple Watch
        NotificationCenter.default.addObserver(self, selector: #selector(watchModel),
                     name: NSNotification.Name(rawValue: "DID_RECEIVE_MESSAGE"),
                     object: nil)
        
        // Get views
        let loadingViewController: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: LOAD_VIEW_ID))!
        let masterView: UIView = self.view
        // Set up loading model
        self.loadingModel = LoadingModel(loadingViewController: loadingViewController,
                                         masterView: masterView)
        // Start counting
        self.loadingModel?.keepAlive()
        
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

