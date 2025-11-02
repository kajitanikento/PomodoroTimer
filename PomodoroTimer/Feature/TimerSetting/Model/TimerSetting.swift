//
//  TimerSetting.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/02.
//

struct TimerSetting {
    // MARK: 表示
    var isShowAmountLabel: Bool
    var isShowCharacter: Bool
    var isShowStopButton: Bool
    // MARK: 機能制御
    var isSoundOn: Bool
    var isSnapToMinute: Bool
    
    static let `default`: Self = .init(
        isShowAmountLabel: true,
        isShowCharacter: true,
        isShowStopButton: true,
        isSoundOn: false,
        isSnapToMinute: true
    )
}
