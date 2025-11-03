//
//  ResetTimerSettingUseCase.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import Foundation

struct ResetTimerSettingUseCase {
    private let repository: TimerSettingRepository
    
    init(repository: TimerSettingRepository = SwiftDataTimerSettingRepository()) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.delete()
        let defaultSetting = TimerSetting.default
        try await repository.save(defaultSetting)
    }
}
