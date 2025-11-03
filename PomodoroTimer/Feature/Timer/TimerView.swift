//
//  TimerView.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/10/25.
//

import SwiftUI
import SwiftData

struct TimerView: View {
    
    @Bindable var viewModel: TimerViewModel
    @Environment(\.modelContext) private var modelContext
    
    init(viewModel: TimerViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Settings", systemImage: "gearshape.fill") {
                            viewModel.onTapSetting()
                        }
                        .tint(.gray)
                    }
                }
                .sheet(item: $viewModel.destinationSheet) { destination in
                    switch destination {
                    case .setting:
                        TimerSettingView(
                            setting: $viewModel.setting
                        )
                    }
                }
                .onAppear(perform: viewModel.onAppear)
        }
    }
    
    var content: some View {
        ZStack {
            if let recordType = viewModel.record?.type {
                recordType.backgroundColor.opacity(0.4)
                    .ignoresSafeArea()
            }
            VStack(spacing: 40) {
                VStack(spacing: 20) {
                    timeSelectorClock
                    if viewModel.setting.isShowAmountLabel {
                        timerLabel
                    }
                }
                
                Spacer()
                
                VStack {
                    if viewModel.setting.isShowCharacter {
                        HStack {
                            character
                            Spacer(minLength: 0)
                        }
                    }
                    if viewModel.setting.isShowStopButton,
                       viewModel.isRecording {
                        stopButton
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Subviews
    
    // MARK: TimeSelect
    
    var timeSelectorClock: some View {
        DraggableTimerView(
            angle: $viewModel.timeSelectAngle,
            isEditing: $viewModel.isEditingTimeSelectAngle,
            isSnapToMinute: viewModel.setting.isSnapToMinute,
            effectTimeColor: Color.red.opacity(0.8),
            backgroundColor: .white,
            onEdited: { angle in
                viewModel.onEditedTimer(angle: angle)
            }
        )
    }
    
    // MARK: Timer label
    
    @ViewBuilder
    var timerLabel: some View {
        Text(viewModel.remainingTimeFormatted ?? "00:00")
            .font(.system(size: 60, weight: .bold))
            .foregroundStyle(Color.Asset.Text.blackPrimary)
            .monospacedDigit()
            .opacity(viewModel.remainingTimeFormatted == nil ? 0.8 : 1)
    }
    
    @ViewBuilder
    var character: some View {
        if viewModel.isRecording {
            CatView(
                .catOnBall,
                width: 120
            )
        } else {
            CatView(
                .waitCat,
                width: 100
            )
        }
    }
    
    func catGif(_ asset: GifAsset.Cat) -> some View {
        GifImage(asset)
            .scaledToFit()
    }
    
    var stopButton: some View {
        Button(action: viewModel.onTapStopTimer) {
            Image(systemName: "stop.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20)
                .padding(20)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .background((viewModel.record?.type.backgroundColor ?? .blue).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .glassEffect()
        }
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
