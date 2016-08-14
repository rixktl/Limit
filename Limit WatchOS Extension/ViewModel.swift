//
//  ViewModel.swift
//  Limit
//
//  Created by Rix Lai on 8/11/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import WatchKit

/* A model that manage view and its content */

public class ViewModel: NSObject {
    
    private var interfaceGroup: WKInterfaceGroup?
    private var speedLabel: WKInterfaceLabel?
    private var unitLabel: WKInterfaceLabel?
    
    private let DEFAULT_UNIT: String! = "M P H"
    private let DEFAULT_SPEED: String! = "0"
    private let DEFAULT_IMAGE_NAME: String! = "single"
    private let EMPTY: String! = ""
    private let STOPPED_IMAGE_NAME: String! = "Start"
    private let OPTIONAL_STOP_IMAGE_NAME: String! = "OptionalStop"
    
    init(inout ig: WKInterfaceGroup, inout sLabel: WKInterfaceLabel,
               inout uLabel: WKInterfaceLabel) {
        interfaceGroup = ig
        speedLabel = sLabel
        unitLabel = uLabel
    }
    
    public func normalView(speed: Double!, speedLimit: Double?, unit: String!) {
        guard (speedLabel != nil && unitLabel != nil) else {
            return
        }
        
        speedLabel!.setText(  String( Int(round(speed)) )  )
        unitLabel!.setText(unit)
    }
    
    public func startedView() {
        print("Started View")
        speedLabel?.setText(DEFAULT_SPEED)
        unitLabel?.setText(DEFAULT_UNIT)
        interfaceGroup?.setBackgroundImageNamed(DEFAULT_IMAGE_NAME)
    }
    
    public func stoppedView() {
        print("Stopped View")
        speedLabel?.setText(EMPTY)
        unitLabel?.setText(EMPTY)
        interfaceGroup?.setBackgroundImageNamed(STOPPED_IMAGE_NAME)
    }
    
    public func optionalStopView() {
        print("Optional Stop View")
        speedLabel?.setText(EMPTY)
        interfaceGroup?.setBackgroundImageNamed(OPTIONAL_STOP_IMAGE_NAME)
    }
}
