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
    fileprivate let LOCATION_REQUEST_VIEW: String = "LocationRequestView"
    fileprivate let watchModel: WatchCommunicationModel = WatchCommunicationModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
      launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Start WCSession for Apple Watch if possible
        if(WCSession.isSupported()) {
            WCSession.default().delegate = self
            WCSession.default().activate()
        }
        
        // Check whether location service is accessable
        if(CLLocationManager.authorizationStatus()
         != CLAuthorizationStatus.authorizedAlways) {
            // Switch to location request view
            let storyboard: UIStoryboard = (self.window?.rootViewController?.storyboard)!
            let rootViewController: UIViewController = storyboard.instantiateViewController(
                                       withIdentifier: LOCATION_REQUEST_VIEW)
            self.window?.rootViewController = rootViewController
            self.window?.makeKeyAndVisible()
        }
        
        // Disable idle (prevent from screen off)
        UIApplication.shared.isIdleTimerDisabled = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /* Sent when the application is about to move from active to inactive state.
           This can occur for certain types of temporary interruptions (such as an
           incoming phone call or SMS message) or when the user quits the application
           and it begins the transition to the background state.
        */
        /* Use this method to pause ongoing tasks, disable timers, and throttle down
           OpenGL ES frame rates. Games should use this method to pause the game.
        */
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        /* Use this method to release shared resources, save user data, invalidate
           timers, and store enough application state information to restore your
           application to its current state in case it is terminated later.
        */
        /* If your application supports background execution, this method is called
           instead of applicationWillTerminate: when the user quits.
        */
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DID_ENTER_BACKGROUND"),
                                        object: self)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        /* Called as part of the transition from the background to the inactive state;
           here you can undo many of the changes made on entering the background.
        */
        NotificationCenter.default.post(name: Notification.Name(rawValue: "WILL_ENTER_FOREGROUND"),
                                        object: self)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        /* Restart any tasks that were paused (or not yet started) while the application
           was inactive. If the application was previously in the background, optionally
           refresh the user interface.
        */
    }

    func applicationWillTerminate(_ application: UIApplication) {
        /* Called when the application is about to terminate. Save data if appropriate.
           See also applicationDidEnterBackground:.
        */
    }

    
    /* Required by WCSession */
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    /* Required by WCSession */
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    /* Required by WCSession */
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        
    }
    
    /* Receive message from Apple Watch */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DID_RECEIVE_MESSAGE"),
                                        object: self, userInfo: message)
        watchModel.newMessage(message)
    }
    
    
}

