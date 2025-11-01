//
//  Minute.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/10/26.
//

import Foundation

struct Minute {
    var value: Int
    
    init(_ value: Int) {
        self.value = value
    }
    
    var second: Int {
        value * 60
    }
    
    var timeIntervalSecond: TimeInterval {
        TimeInterval(value) * 60
    }
}
