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
    func updateSettings(_ settings: Settings!)
}

open class SettingModel: NSObject {
    
    fileprivate let userDefaults: UserDefaults = UserDefaults.standard
    fileprivate let UNIT_NAME: String = "UNIT_IS_MPH"
    fileprivate let ACCURACY_NAME: String = "ACCURACY_IS_EXACT"
    fileprivate var settings: Settings! = Settings()
    internal var delegate: SettingModelDelegate!
    
    override init() {
        super.init()
        // Add self to observer for unit changes
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeSetting),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
    }
    
    deinit {
        // Remove observer when deallocate
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification,
                                                  object: nil)
    }
    
    /* Called when receive change in setting */
    internal func didChangeSetting() {
        self.settings.isMPH = getSettingWithDefault(UNIT_NAME, defaultBoolean: Settings().isMPH)
        self.settings.isExact = getSettingWithDefault(ACCURACY_NAME,
                                                      defaultBoolean: Settings().isExact)
        delegate?.updateSettings(self.settings)
    }
    
    /* Flip accuracy */
    open func flipAccuracy() {
        let boolUnit: Bool! = flipSetting(ACCURACY_NAME, defaultBoolean: Settings().isExact)
        self.settings.isExact = boolUnit
        delegate?.updateSettings(self.settings)
    }
    
    /* Flip unit */
    open func flipUnit() {
        let boolUnit: Bool! = flipSetting(UNIT_NAME, defaultBoolean: Settings().isMPH)
        self.settings.isMPH = boolUnit
        delegate?.updateSettings(self.settings)
    }
    
    /* Flip unit */
    fileprivate func flipSetting(_ key: String!, defaultBoolean: Bool!) -> Bool! {
        
        // Boolean setting
        let boolSetting = getSettingWithDefault(key, defaultBoolean: defaultBoolean)
        
        if (boolSetting == true) {
            userDefaults.set(false, forKey: key)
            return false
            
        } else {
            userDefaults.set(true, forKey: key)
            return true
        }

    }
    
    /* Get setting with given default value */
    fileprivate func getSettingWithDefault(_ key: String!, defaultBoolean: Bool!) -> Bool! {
        
        // Get info
        let info = userDefaults.object(forKey: key)
        
        // Check if user setting for info exist
        if(info == nil) {
            // Write into setting, do not use synchronize
            userDefaults.set(defaultBoolean, forKey: key)
            return defaultBoolean
            
        } else {
            // Boolean info
            let boolInfo = userDefaults.bool(forKey: key)
            
            if (boolInfo == true) {
                return true
                
            } else {
                return false
            }
        }
        
    }
    
    
}
