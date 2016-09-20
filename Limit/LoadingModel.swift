//
//  LoadingModel.swift
//  Limit
//
//  Created by Rix Lai on 7/3/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import UIKit

/*
 * A model that show a loading view
 */

open class LoadingModel: NSObject {
    
    fileprivate let TIMER_DELAY: Double! = 2.0
    
    fileprivate var loadingView: UIView?
    fileprivate var masterView: UIView?
    fileprivate var timer: Timer? = Timer()
    
    init(loadingViewController: UIViewController!, masterView: UIView!) {
        // Prepare loading view controller
        loadingViewController.viewWillAppear(false)
        loadingViewController.viewDidLoad()
        
        self.loadingView = loadingViewController!.view
        self.masterView = masterView
    }
    
    /* Disable loading view for a while */
    open func keepAlive() {
        if(timer != nil) {
            // Cancel scheduled job
            timer!.invalidate()
        }
        // Remove timer
        timer = nil
        // Delayed call
        timer = Timer.scheduledTimer(timeInterval: TIMER_DELAY, target: self, selector: #selector(addView), userInfo: nil, repeats: false)
    }
    
    /* Stop loading model */
    open func stop() {
        if(timer != nil) {
            // Cancel scheduled job
            timer!.invalidate()
        }
        // Remove timer
        timer = nil
    }
    
    /* Add loading view to master view */
    open func addView() {
        // Ensure subview is not added
        guard (!(self.loadingView!.isDescendant(of: self.masterView!))  ) else {
            return
        }
        DispatchQueue.main.async(execute: {
            self.masterView!.addSubview(self.loadingView!)
        })
    }
    
    /* Remove loading view from master view */
    open func removeView() {
        // Ensure subview is added
        guard (self.loadingView!.isDescendant(of: self.masterView!)) else {
            return
        }
        DispatchQueue.main.async(execute: {
            self.loadingView!.removeFromSuperview()
        })
    }
    
}
