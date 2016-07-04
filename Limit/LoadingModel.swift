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
    private var addLock: Bool! = false
    private var removeLock: Bool! = false
    private var timer: NSTimer? = NSTimer()
    
    init(loadingViewController: UIViewController!, masterView: UIView!) {
        loadingViewController.viewWillAppear(false)
        loadingViewController.viewDidLoad()
        
        self.loadingView = loadingViewController!.view
        self.masterView = masterView
    }
    
    public func keepAlive() {
        if(timer != nil) {
            timer!.invalidate()
        }
        timer = nil
        timer = NSTimer.scheduledTimerWithTimeInterval(TIMER_DELAY, target: self, selector: #selector(addView), userInfo: nil, repeats: false)
    }
    
    public func stop() {
        if(timer != nil) {
            timer!.invalidate()
        }
        timer = nil
    }
    
    public func addView() {
        print("Requesting to add")
        
        guard (self.loadingView!.superview == nil) else {
            return
        }
        
        /*
        guard (!(self.loadingView!.isDescendantOfView(self.masterView!))  ) else {
            return
        }
        */
        print("Adding")
        dispatch_async(dispatch_get_main_queue(), {
            self.masterView!.addSubview(self.loadingView!)
        })
    }
    
    public func removeView() {
        print("Requesting to remove")
        guard (self.loadingView!.superview != nil) else {
            return
        }
        /*
        guard (self.loadingView!.isDescendantOfView(self.masterView!)) else {
            return
        }
        */
        print("Removing")
        dispatch_async(dispatch_get_main_queue(), {
            self.loadingView!.removeFromSuperview()
        })
    }
    
}