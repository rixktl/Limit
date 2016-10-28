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

open class AudioModel: NSObject {
    fileprivate let path: String = Bundle.main.resourcePath! + "/DoubleBeep.mp3"
    fileprivate let AUDIO_OFFSET: Double! = 0.0
    
    fileprivate var lock: Bool! = false
    fileprivate var audioPlayer: AVAudioPlayer?
    
    override init() {
        do {
            // Set up audio player
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.path))
        } catch _ {
            // TODO: handle error, audio file cannot be loaded
            print("Cannot load audio file")
        }
        
        super.init()
    }
    
    /* Request to play audio */
    open func play() {
        // Ensure status ok
        guard (self.lock != true && self.audioPlayer != nil) else {
            return
        }
        
        self.lock = true
        self.audioPlayer!.play()
        
        // Delay unlock
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() +
         Double(Int64(self.audioPlayer!.duration + AUDIO_OFFSET * Double(NSEC_PER_SEC))) /
         Double(NSEC_PER_SEC), execute: ({
            self.lock = false
        }))
        
    }
    
}
