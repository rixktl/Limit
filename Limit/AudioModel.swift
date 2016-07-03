//
//  AudioModel.swift
//  Limit
//
//  Created by Rix Lai on 7/2/16.
//  Copyright © 2016 Limit Labs. All rights reserved.
//

import Foundation
import AVFoundation

/*
 * A model that handle audio player
 */

public class AudioModel: NSObject {
    private let path: String! = NSBundle.mainBundle().resourcePath! + "/DoubleBeep.mp3"
    private let AUDIO_OFFSET: Double! = 0.0
    
    public var inBackground: Bool! = false
    private var lock: Bool! = false
    private var audioPlayer: AVAudioPlayer?
    
    override init() {
        do {
            // Set up audio player
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(self.path))
        } catch _ {
            // TODO: handle error, audio file cannot be loaded
            print("Cannot load audio file")
        }
        
        super.init()
        // Background means it really just in background
        // Need to research on detecting whether launched by Apple Watch
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didEnterBackground), name: "DID_ENTER_BACKGROUND", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willEnterForeground), name: "WILL_ENTER_FOREGROUND", object: nil)
    }
    
    /* Deallocate */
    deinit {
        // Remove observer
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DID_ENTER_BACKGROUND", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "WILL_ENTER_FOREGROUND", object: nil)
    }
    
    /* Entered background (opened by AppleWatch) */
    internal func didEnterBackground() {
        self.inBackground = true
    }
    
    /* Entering foreground */
    internal func willEnterForeground() {
        self.inBackground = false
    }
    
    /* Request to play audio */
    public func play() {
        // Ensure status ok
        guard (self.lock != true && self.audioPlayer != nil) else {
            return
        }
        
        self.lock = true
        self.audioPlayer!.play()
        
        // Delay unlock
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self.audioPlayer!.duration + AUDIO_OFFSET * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), ({
            self.lock = false
        }))
        
    }
    
}
