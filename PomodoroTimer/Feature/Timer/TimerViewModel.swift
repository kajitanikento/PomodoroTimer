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
    
    var destinationSheet: DestinationSheet?
    
    var record: Record?
    private var recordTimer = AsyncTimerSequence(interval: .seconds(1), clock: .continuous)
    private var recordTimerTask: Task<Void, Never>?
    
    var remainingTimeFormatted: String?
    
    var isEditingTimeSelectAngle = false
    var timeSelectAngle: Double = 0
    
    var setting: TimerSetting
    var isSoundOn = false
    
    // MARK: Dependency
    private let systemSoundPlayer: SystemSoundPlayer
    
    init(
        timerSetting: TimerSetting = .default,
        systemSoundPlayer: SystemSoundPlayer = .init()
    ) {
        setting = timerSetting
        self.systemSoundPlayer = systemSoundPlayer
    }
    
    var isRecording: Bool {
        record != nil
    }
    
    func onEditedTimer(angle: Double) {
        guard angle > 0 else {
            endRecordTimer()
            return
        }
        let durationSecond = Int(angle * 10)
        startRecordTimer(durationSecond: durationSecond, type: record?.type == .shortBreak ? .shortBreak : .focus)
    }
    
    private func startRecordTimer(durationSecond: Int, type: RecordType) {
        record = .init(
            startedAt: .now,
            durationSecond: durationSecond,
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
    
    func onTapStopTimer() {
        endRecordTimer()
    }
    
    private func endRecordTimer() {
        record = nil
        remainingTimeFormatted = nil
        recordTimerTask?.cancel()
        timeSelectAngle = 0
        playSystemSoundIfNeeded(sound: .endVideoRecording)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func handleRecordTimer() {
        guard let record else { return }
        let endScheduleDate = record.startedAt.addingTimeInterval(TimeInterval(record.durationSecond + 1))
        
        if endScheduleDate < .now {
            endRecordTimer()
//            startRecordTimer(
//                durationSecond: record.type == .focus ? Minute(5).second : Minute(25).second,
//                type: record.type == .focus ? .shortBreak : .focus
//            )
            return
        }
        
        updateRemainingTime(endScheduleDate: endScheduleDate)
    }
    
    private func updateRemainingTime(endScheduleDate: Date) {
        guard !isEditingTimeSelectAngle else { return }
        
        let timeInterval = endScheduleDate.timeIntervalSince(.now)
        timeSelectAngle = timeInterval / 10
        
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
    
    func onTapSetting() {
        destinationSheet = .setting
    }
}

extension TimerViewModel {
    enum DestinationSheet: String, Identifiable {
        case setting
        
        var id: String {
            rawValue
        }
    }
}
