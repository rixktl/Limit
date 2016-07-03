//
//  SettingModel.swift
//  Limit
//
//  Created by Rix Lai on 7/3/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation

/*
 * A model that handles settings
 */

struct Settings{
    var isMPH: Bool! = true
    var isExact: Bool! = false
}

internal protocol SettingModelDelegate {
    func updateSettings(settings: Settings!)
}

public class SettingModel: NSObject {
    
    private let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    private let UNIT_NAME: String! = "UNIT_IS_MPH"
    private let ACCURACY_NAME: String! = "ACCURACY_IS_EXACT"
    private var settings: Settings! = Settings()
    internal var delegate: SettingModelDelegate!
    
    override init() {
        super.init()
        // Add self to observer for unit changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didChangeSetting), name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    deinit {
        // Remove observer when deallocate
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    /* Called when receive change in setting */
    internal func didChangeSetting() {
        self.settings.isMPH = getSettingWithDefault(UNIT_NAME, defaultBoolean: Settings().isMPH)
        self.settings.isExact = getSettingWithDefault(ACCURACY_NAME, defaultBoolean: Settings().isExact)
        delegate?.updateSettings(self.settings)
    }
    
    /* Flip accuracy */
    public func flipAccuracy() {
        let boolUnit: Bool! = flipSetting(ACCURACY_NAME, defaultBoolean: Settings().isExact)
        self.settings.isExact = boolUnit
        delegate?.updateSettings(self.settings)
    }
    
    /* Flip unit */
    public func flipUnit() {
        let boolUnit: Bool! = flipSetting(UNIT_NAME, defaultBoolean: Settings().isMPH)
        self.settings.isMPH = boolUnit
        delegate?.updateSettings(self.settings)
    }
    
    /* Flip unit */
    private func flipSetting(key: String!, defaultBoolean: Bool!) -> Bool! {
        
        // Boolean setting
        let boolSetting = getSettingWithDefault(key, defaultBoolean: defaultBoolean)
        
        if (boolSetting == true) {
            userDefaults.setBool(false, forKey: key)
            return false
            
        } else {
            userDefaults.setBool(true, forKey: key)
            return true
        }

    }
    
    /* Get setting with given default value */
    private func getSettingWithDefault(key: String!, defaultBoolean: Bool!) -> Bool! {
        
        // Get info
        let info = userDefaults.objectForKey(key)
        
        // Check if user setting for info exist
        if(info == nil) {
            // Write into setting, do not use synchronize
            userDefaults.setBool(defaultBoolean, forKey: key)
            return defaultBoolean
            
        } else {
            // Boolean info
            let boolInfo = userDefaults.boolForKey(key)
            
            if (boolInfo == true) {
                return true
                
            } else {
                return false
            }
        }
        
    }
    
    
}
