//
//  ExtensionDelegate.swift
//  Limit WatchOS Extension
//
//  Created by Rix Lai on 7/4/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }


    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        // Start WCSession for iPhone if possible
        if(WCSession.isSupported()) {
            WCSession.default().delegate = self
            WCSession.default().activate()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    /* Receive message from iPhone */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DID_RECEIVE_MESSAGE"), object: self, userInfo: message)
    }

}
