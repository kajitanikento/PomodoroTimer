//
//  TimerSettingRepository.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import Foundation

protocol TimerSettingRepository {
    func fetch() async throws -> TimerSetting?
    func save(_ setting: TimerSetting) async throws
    func update(_ setting: TimerSetting) async throws
    func delete() async throws
}
