//
//  TimerSettingData.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import SwiftData
import Foundation

@Model
final class TimerSettingData {
    var isShowAmountLabel: Bool
    var isShowCharacter: Bool
    var isShowStopButton: Bool
    var isSoundOn: Bool
    var isSnapToMinute: Bool
    
    init(
        isShowAmountLabel: Bool = true,
        isShowCharacter: Bool = true,
        isShowStopButton: Bool = true,
        isSoundOn: Bool = false,
        isSnapToMinute: Bool = true
    ) {
        self.isShowAmountLabel = isShowAmountLabel
        self.isShowCharacter = isShowCharacter
        self.isShowStopButton = isShowStopButton
        self.isSoundOn = isSoundOn
        self.isSnapToMinute = isSnapToMinute
    }
}

extension TimerSettingData {
    func toTimerSetting() -> TimerSetting {
        TimerSetting(
            isShowAmountLabel: isShowAmountLabel,
            isShowCharacter: isShowCharacter,
            isShowStopButton: isShowStopButton,
            isSoundOn: isSoundOn,
            isSnapToMinute: isSnapToMinute
        )
    }
}

extension TimerSetting {
    func toTimerSettingData() -> TimerSettingData {
        TimerSettingData(
            isShowAmountLabel: isShowAmountLabel,
            isShowCharacter: isShowCharacter,
            isShowStopButton: isShowStopButton,
            isSoundOn: isSoundOn,
            isSnapToMinute: isSnapToMinute
        )
    }
}
