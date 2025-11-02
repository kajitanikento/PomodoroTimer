//
//  DraggableTimerView.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/10/27.
//

import SwiftUI

struct DraggableTimerView: View {
    // 0°(12時)～360° 時計回り
    @Binding var angle: Double
    @Binding var isEditing: Bool
    var isSnapToMinute: Bool
    var effectTimeColor: Color = .red
    var backgroundColor: Color = .white
    var onEdited: (Double) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                let side = min(geometry.size.width, geometry.size.height)
                let radius = side / 2
                
                ZStack {
                    durationIndicator
                    dial(radius: radius)
                    clockHands(radius: radius)
                }
                .frame(width: side, height: side)
                .background(backgroundColor)
                .contentShape(Circle())
                .clipShape(Circle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard isEditing else { return }
                            let newAngle = angleFromTop(location: value.location, in: geometry.size)
                            
                            // 一周しないようにする
                            if (angle > 300 && newAngle < 60) ||
                                (angle < 60 && newAngle > 300) {
                                return
                            }
                            // 不自然な角度移動を防止
                            if abs(angle - newAngle) > 90 {
                                return
                            }
                            // 0°指定がしにくいので
                            if angle > 5,
                               newAngle <= 4 {
                                angle = 0
                                return
                            }
                            
                            angle = isSnapToMinute ? snapAngle(newAngle, step: 6) : newAngle
                        }
                )
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
    
    // MARK: - Subviews
    
    private var durationIndicator: some View {
        DurationIndicator(endAngle: angle, inset: 10)
            .fill(effectTimeColor)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
    
    /// 文字盤
    @ViewBuilder
    private func dial(radius: CGFloat) -> some View {
        Circle()
            .stroke(.secondary, lineWidth: 2)
        // 目盛り（5分ごとを太く）
        ForEach(0..<60) { i in
            Capsule()
                .frame(width: i % 5 == 0 ? 3 : 1,
                       height: i % 5 == 0 ? 14 : 6)
                .offset(y: -radius + 10)
                .rotationEffect(.degrees(Double(i) * 6))
                .opacity(i % 5 == 0 ? 1 : 0.6)
        }
    }
    
    /// 時計の針
    @ViewBuilder
    private func clockHands(radius: CGFloat) -> some View {
        Capsule()
            .frame(width: 6, height: radius)
            .padding(12)
            .offset(y: -radius * 0.45)
            .rotationEffect(.degrees(-angle))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isEditing = true
                    }
                    .onEnded { _ in
                        isEditing = false
                        onEdited(angle)
                    }
            )
        Circle()
            .fill(.primary)
            .frame(width: 10, height: 10)
    }
    
    // MARK: - Helpers
    
    /// 12時=0°, 反時計回りに増加（9時=90°, 6時=180°, 3時=270°）
    private func angleFromTop(location: CGPoint, in size: CGSize) -> Double {
        let cx = size.width / 2
        let cy = size.height / 2
        let dx = location.x - cx
        let dy = location.y - cy
        // 画面座標の atan2 は実質「時計回りが正」になるので、符号を反転しつつ12時を基準にずらす
        var deg = -atan2(dy, dx) * 180 / .pi - 90
        deg.formTruncatingRemainder(dividingBy: 360)
        if deg < 0 { deg += 360 }
        return deg
    }
    
    private func snapAngle(_ deg: Double, step: Double) -> Double {
        (deg / step).rounded() * step
    }
}

/// 12時=0°, 反時計回り endAngle 度までを塗る扇形
private struct DurationIndicator: Shape {
    var endAngle: Double
    // 外周ストロークや目盛りと干渉しないよう内側に引っ込める量
    var inset: CGFloat = 8
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let side = min(rect.width, rect.height)
        let r = side / 2 - inset
        let c = CGPoint(x: rect.midX, y: rect.midY)
        
        guard endAngle > 0 else { return p }
        
        // 360°ちょうどは特殊扱い（閉じた円）
        if endAngle >= 360 {
            p.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
            return p
        }
        
        p.move(to: c)
        // Pathは「右=0°、反時計回りが正」。12時は -90°
        p.addArc(center: c,
                 radius: r,
                 startAngle: .degrees(-90),
                 endAngle: .degrees(-90 + endAngle),
                 clockwise: false)
        p.closeSubpath()
        return p
    }
}

#if DEBUG
private struct PreviewContent: View {
    @State var angle: Double = 0
    @State var isEditing = false
    
    var body: some View {
        DraggableTimerView(
            angle: $angle,
            isEditing: $isEditing,
            isSnapToMinute: true,
            effectTimeColor: Color.blue.opacity(0.28),
            backgroundColor: .orange
        )
    }
}

#Preview {
    PreviewContent()
}
#endif

