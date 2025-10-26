//
//  TimerView.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/10/25.
//

import SwiftUI

struct TimerView: View {
    
    @Bindable var viewModel = TimerViewModel()
    
    var body: some View {
        ZStack {
            if let recordType = viewModel.record?.type {
                recordType.backgroundColor.opacity(0.4)
                    .ignoresSafeArea()
            }
            timerLabels
            bottomButtons
        }
    }
    
    // MARK: Timer label
    
    @ViewBuilder
    var timerLabels: some View {
        if viewModel.isRecording {
            activeTimerLabels
        } else {
            deactiveTimerLabels
        }
    }
    
    var activeTimerLabels: some View {
        VStack(spacing: 4) {
            if let remainingTime = viewModel.remainingTimeFormatted {
                Text(remainingTime)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.Asset.Text.blackPrimary)
                    .monospacedDigit()
            }
            if let record = viewModel.record {
                Text(record.type.label)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .foregroundStyle(.white)
                    .background(record.type.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
    
    var deactiveTimerLabels: some View {
        Text("(´・ω・) < just do it.")
            .font(.system(size: 32, weight: .bold))
            .foregroundStyle(Color.Asset.Text.blackPrimary)
    }
    
    // MARK: Bottom buttons
    
    var bottomButtons: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Spacer()
                switchSoundButton
                switchTimerButton
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    var switchTimerButton: some View {
        if viewModel.isRecording {
            stopButton
        } else {
            startButton
        }
    }
    
    var startButton: some View {
        Button(action: {
            viewModel.startRecordTimer(type: .focus)
        }) {
            buttonImage("play.fill", backgroundColor: .blue)
        }
    }
    
    var stopButton: some View {
        Button(action: viewModel.endRecordTimer) {
            buttonImage("stop.fill", backgroundColor: viewModel.record?.type.backgroundColor ?? .blue)
        }
    }
    
    var switchSoundButton: some View {
        Button(action: {
            viewModel.isSoundOn.toggle()
        }) {
            buttonImage(
                viewModel.isSoundOn ? "speaker.wave.2.fill" : "speaker.slash.fill",
                backgroundColor: .gray
            )
        }
    }
    
    func buttonImage(
        _ systemName: String,
        backgroundColor: Color
    ) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: 20)
            .padding(20)
            .foregroundStyle(.white)
            .background(backgroundColor.opacity(0.8))
            .clipShape(Circle())
            .glassEffect()
    }
}

private extension RecordType {
    
    var label: String {
        switch self {
        case .focus: "集中"
        case .shortBreak: "休憩"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .focus: .blue
        case .shortBreak: .orange
        }
    }
    
}

#if DEBUG
#Preview {
    TimerView()
}
#endif
