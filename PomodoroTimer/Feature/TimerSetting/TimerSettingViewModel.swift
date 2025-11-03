//
//  TimerSettingViewModel.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/01.
//

import Observation

@Observable
final class TimerSettingViewModel {
    private let saveTimerSettingUseCase: SaveTimerSettingUseCase
    
    init(saveTimerSettingUseCase: SaveTimerSettingUseCase = .init()) {
        self.saveTimerSettingUseCase = saveTimerSettingUseCase
    }
    
    func onChangeSetting(_ setting: TimerSetting) {
        Task {
            try? await saveTimerSettingUseCase.execute(setting)
        }
    }
}
