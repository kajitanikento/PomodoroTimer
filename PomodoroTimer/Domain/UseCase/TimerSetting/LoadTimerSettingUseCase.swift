//
//  LoadTimerSettingUseCase.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import Foundation

struct LoadTimerSettingUseCase {
    private let repository: TimerSettingRepository
    
    init(repository: TimerSettingRepository = SwiftDataTimerSettingRepository()) {
        self.repository = repository
    }
    
    func execute() async -> TimerSetting {
        do {
            if let setting = try await repository.fetch() {
                return setting
            } else {
                let defaultSetting = TimerSetting.default
                try await repository.save(defaultSetting)
                return defaultSetting
            }
        } catch {
            return TimerSetting.default
        }
    }
}
