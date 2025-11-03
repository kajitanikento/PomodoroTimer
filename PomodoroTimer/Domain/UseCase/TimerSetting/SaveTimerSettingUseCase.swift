//
//  SaveTimerSettingUseCase.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import Foundation

struct SaveTimerSettingUseCase {
    private let repository: TimerSettingRepository
    
    init(repository: TimerSettingRepository = SwiftDataTimerSettingRepository()) {
        self.repository = repository
    }
    
    func execute(_ setting: TimerSetting) async throws {
        try await repository.update(setting)
    }
}
