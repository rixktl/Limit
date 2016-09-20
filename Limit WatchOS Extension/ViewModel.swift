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

open class ViewModel: NSObject {
    
    fileprivate var interfaceGroup: WKInterfaceGroup?
    fileprivate var speedLabel: WKInterfaceLabel?
    fileprivate var unitLabel: WKInterfaceLabel?
    
    fileprivate let DEFAULT_UNIT: String = "M P H"
    fileprivate let DEFAULT_SPEED: String = "0"
    fileprivate let DEFAULT_IMAGE_NAME: String = "single"
    fileprivate let EMPTY: String = ""
    fileprivate let STOPPED_IMAGE_NAME: String = "Start"
    fileprivate let OPTIONAL_STOP_IMAGE_NAME: String = "OptionalStop"
    
    init(ig: inout WKInterfaceGroup, sLabel: inout WKInterfaceLabel,
               uLabel: inout WKInterfaceLabel) {
        interfaceGroup = ig
        speedLabel = sLabel
        unitLabel = uLabel
    }
    
    open func normalView(_ speed: Double!, speedLimit: Double?, unit: String!) {
        guard (speedLabel != nil && unitLabel != nil) else {
            return
        }
        
        print("Normal View")
        
        speedLabel!.setText(  String( Int(round(speed)) )  )
        unitLabel!.setText(unit)
    }
    
    open func startedView() {
        print("Started View")
        speedLabel?.setText(DEFAULT_SPEED)
        unitLabel?.setText(DEFAULT_UNIT)
        interfaceGroup?.setBackgroundImageNamed(DEFAULT_IMAGE_NAME)
    }
    
    open func stoppedView() {
        print("Stopped View")
        speedLabel?.setText(EMPTY)
        unitLabel?.setText(EMPTY)
        interfaceGroup?.setBackgroundImageNamed(STOPPED_IMAGE_NAME)
    }
    
    open func optionalStopView(_ unit: String!) {
        print("Optional Stop View")
        speedLabel?.setText(EMPTY)
        unitLabel!.setText(unit)
        interfaceGroup?.setBackgroundImageNamed(OPTIONAL_STOP_IMAGE_NAME)
    }
}
