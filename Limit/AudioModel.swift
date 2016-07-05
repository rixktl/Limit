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
