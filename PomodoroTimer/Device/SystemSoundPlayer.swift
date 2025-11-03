//
//  SystemSoundPlayer.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/10/26.
//

import AVFoundation

struct SystemSoundPlayer {
    
    func play(sound: SystemSound) {
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }
    
}

enum SystemSound: UInt32 {
    case mediaPaused = 1368
    case mediaHandoff = 1369
    
    var systemSoundID: SystemSoundID {
        self.rawValue as SystemSoundID
    }
}
