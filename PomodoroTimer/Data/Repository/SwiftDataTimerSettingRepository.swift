//
//  SwiftDataTimerSettingRepository.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import Foundation
import SwiftData

struct SwiftDataTimerSettingRepository: TimerSettingRepository {
    @MainActor
    private var modelContext: ModelContext {
        SharedModelContext.container.mainContext
    }

    init() {}
    
    func fetch() async throws -> TimerSetting? {
        let descriptor = FetchDescriptor<TimerSettingData>()
        let results = try modelContext.fetch(descriptor)
        return results.first?.toTimerSetting()
    }
    
    func save(_ setting: TimerSetting) async throws {
        let settingData = setting.toTimerSettingData()
        modelContext.insert(settingData)
        try modelContext.save()
    }
    
    func update(_ setting: TimerSetting) async throws {
        let descriptor = FetchDescriptor<TimerSettingData>()
        let results = try modelContext.fetch(descriptor)
        
        if let existingData = results.first {
            existingData.isShowAmountLabel = setting.isShowAmountLabel
            existingData.isShowCharacter = setting.isShowCharacter
            existingData.isShowStopButton = setting.isShowStopButton
            existingData.isSoundOn = setting.isSoundOn
            existingData.isSnapToMinute = setting.isSnapToMinute
            try modelContext.save()
        } else {
            try await save(setting)
        }
    }
    
    func delete() async throws {
        let descriptor = FetchDescriptor<TimerSettingData>()
        let results = try modelContext.fetch(descriptor)
        
        for data in results {
            modelContext.delete(data)
        }
        try modelContext.save()
    }
}
