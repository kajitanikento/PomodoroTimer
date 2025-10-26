//
//  TimerViewModel.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/10/25.
//

import AsyncAlgorithms
import SwiftUI
import Observation
import Foundation

@Observable
final class TimerViewModel {
    
    var record: Record?
    private var recordTimer = AsyncTimerSequence(interval: .seconds(1), clock: .continuous)
    private var recordTimerTask: Task<Void, Never>?
    
    var remainingTimeFormatted: String?
    
    var isSoundOn = true
    
    // MARK: Dependency
    private let systemSoundPlayer: SystemSoundPlayer
    
    init(
        systemSoundPlayer: SystemSoundPlayer = .init()
    ) {
        self.systemSoundPlayer = systemSoundPlayer
    }
    
    var isRecording: Bool {
        record != nil
    }
    
    func startRecordTimer(type: RecordType) {
        record = .init(
            startedAt: .now,
            durationSecond: type == .focus ? Minute(25).second : Minute(5).second,
            type: type
        )
        playSystemSoundIfNeeded(sound: type == .focus ? .beginVideoRecording : .endVideoRecording)
        UIApplication.shared.isIdleTimerDisabled = true
        
        handleRecordTimer()
        recordTimerTask = Task {
            for await _ in recordTimer {
                handleRecordTimer()
            }
        }
    }
    
    func endRecordTimer() {
        record = nil
        remainingTimeFormatted = nil
        recordTimerTask?.cancel()
        playSystemSoundIfNeeded(sound: .endVideoRecording)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func handleRecordTimer() {
        guard let record else { return }
        let endScheduleDate = record.startedAt.addingTimeInterval(TimeInterval(record.durationSecond + 1))
        
        if endScheduleDate < .now {
            endRecordTimer()
            startRecordTimer(type: record.type == .focus ? .shortBreak : .focus)
            return
        }
        
        updateRemainingTime(endScheduleDate: endScheduleDate)
    }
    
    private func updateRemainingTime(endScheduleDate: Date) {
        let timeInterval = endScheduleDate.timeIntervalSince(.now)
        
        if timeInterval <= 0 {
            remainingTimeFormatted = "00:00"
            return
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours >= 1 {
            remainingTimeFormatted = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            remainingTimeFormatted = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func playSystemSoundIfNeeded(sound: SystemSound) {
        guard isSoundOn else { return }
        systemSoundPlayer.play(sound: sound)
    }
}
