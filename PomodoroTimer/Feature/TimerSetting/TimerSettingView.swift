//
//  TimerSettingView.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/01.
//

import SwiftUI

struct TimerSettingView: View {
    
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel = TimerViewModel()

    @Binding var setting: TimerSetting
    
    var body: some View {
        NavigationStack {
            content
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
    
    private var content: some View {
        List {
            displaySection
            controlSection
        }
    }
    
    private var displaySection: some View {
        Section("表示") {
            Toggle(isOn: $setting.isShowAmountLabel) {
                Text("残り時間を表示")
            }
            Toggle(isOn: $setting.isShowCharacter) {
                Text("キャラクターを表示")
            }
            Toggle(isOn: $setting.isShowStopButton) {
                Text("停止ボタンを表示")
            }
        }
    }
    
    private var controlSection: some View {
        Section("機能制御") {
            Toggle(isOn: $setting.isSoundOn) {
                Text("開始/停止音を再生")
            }
            Toggle(isOn: $setting.isSnapToMinute) {
                Text("タイマーの針を分区切りで動かす")
            }
        }
    }
}

#if DEBUG
#Preview {
    TimerSettingView(setting: .constant(.default))
}
#endif
