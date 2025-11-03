//
//  SharedModelContext.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import SwiftData

struct SharedModelContext {
    private static let schema = Schema([
        TimerSettingData.self
    ])
    
    private static var _container: ModelContainer?
    static var container: ModelContainer {
        if let _container = Self._container {
            return _container
        }
        
        let configration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [configration])
            _container = container
            return container
        } catch {
            fatalError("ModelContainerの生成に失敗, reason: \(error)")
        }
    }
}
