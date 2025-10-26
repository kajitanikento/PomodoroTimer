//
//  Record.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/10/26.
//

import Foundation

struct Record {
    var startedAt: Date
    var endedAt: Date?
    var durationSecond: Int
    var type: RecordType
}

enum RecordType {
    case focus
    case shortBreak
}
