//
//  LoadingModel.swift
//  Limit
//
//  Created by Rix Lai on 7/3/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import UIKit

public class LoadingModel: NSObject {
    
    private let TIMER_DELAY: Double! = 2.0
    
    private var loadingView: UIView?
    private var masterView: UIView?
    private var timer: NSTimer? = NSTimer()
    
    init(loadingViewController: UIViewController!, masterView: UIView!) {
        // Prepare loading view controller
        loadingViewController.viewWillAppear(false)
        loadingViewController.viewDidLoad()
        
        self.loadingView = loadingViewController!.view
        self.masterView = masterView
    }
    
    /* Disable loading view for a while */
    public func keepAlive() {
        if(timer != nil) {
            // Cancel scheduled job
            timer!.invalidate()
        }
        // Remove timer
        timer = nil
        // Delayed call
        timer = NSTimer.scheduledTimerWithTimeInterval(TIMER_DELAY, target: self, selector: #selector(addView), userInfo: nil, repeats: false)
    }
    
    /* Stop loading model */
    public func stop() {
        if(timer != nil) {
            // Cancel scheduled job
            timer!.invalidate()
        }
        // Remove timer
        timer = nil
    }
    
    /* Add loading view to master view */
    public func addView() {
        // Ensure subview is not added
        guard (!(self.loadingView!.isDescendantOfView(self.masterView!))  ) else {
            return
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.masterView!.addSubview(self.loadingView!)
        })
    }
    
    /* Remove loading view from master view */
    public func removeView() {
        // Ensure subview is added
        guard (self.loadingView!.isDescendantOfView(self.masterView!)) else {
            return
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.loadingView!.removeFromSuperview()
        })
    }
    
}
