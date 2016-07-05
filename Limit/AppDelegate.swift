//
//  AppDelegate.swift
//  Limit
//
//  Created by Rix Lai on 6/22/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    private let LOCATION_REQUEST_VIEW: String! = "LocationRequestView"
    private let watchModel: WatchCommunicationModel = WatchCommunicationModel()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Start WCSession for Apple Watch if possible
        if(WCSession.isSupported()) {
            WCSession.defaultSession().delegate = self
            WCSession.defaultSession().activateSession()
        }
        
        // Check whether location service is accessable
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways) {
            // Switch to location request view
            let storyboard: UIStoryboard = (self.window?.rootViewController?.storyboard)!
            let rootViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier(LOCATION_REQUEST_VIEW)
            self.window?.rootViewController = rootViewController
            self.window?.makeKeyAndVisible()
        }
        
        // Disable idle (prevent from screen off)
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSNotificationCenter.defaultCenter().postNotificationName("DID_ENTER_BACKGROUND", object: self)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NSNotificationCenter.defaultCenter().postNotificationName("WILL_ENTER_FOREGROUND", object: self)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /* Receive message from Apple Watch */
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        NSNotificationCenter.defaultCenter().postNotificationName("DID_RECEIVE_MESSAGE", object: self, userInfo: message)
        watchModel.newMessage(message)
    }
    
}

