//
//  DraggableClock.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/10/27.
//

import SwiftUI

struct DraggableClock: View {
    // 0°(12時)～360° 時計回り
    @Binding var angle: Double
    @Binding var isEditing: Bool
    @Binding var isSnapToMinute: Bool
    var effectTimeColor: Color
    var onEdited: (Double) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                let side = min(geometry.size.width, geometry.size.height)
                let radius = side / 2
                
                ZStack {
                    Sector(endAngle: angle, inset: 10)
                        .fill(effectTimeColor)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    
                    // 文字盤
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
                    
                    // 針（デフォルトは上向き＝12時、そこから回転）
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
                    
                    // 中心キャップ
                    Circle()
                        .fill(.primary)
                        .frame(width: 10, height: 10)
                }
                .frame(width: side, height: side)
                .contentShape(Circle()) // 盤面どこでもドラッグ可
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
                            
                            if abs(angle - newAngle) > 90 {
                                return
                            }
                            
                            angle = isSnapToMinute ? snapAngle(newAngle, step: 6) : newAngle
                        }
                )
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(24)
        }
        .padding()
    }
    
    /// 0時=0°, 反時計回りに増加（9時=90°, 6時=180°, 3時=270°）
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
struct Sector: Shape {
    var endAngle: Double          // 0...360 (CCW from 12 o'clock)
    var inset: CGFloat = 8        // 外周ストロークや目盛りと干渉しないよう内側に引っ込める量
    
    // 角度をアニメーション可能に
    var animatableData: Double {
        get { endAngle }
        set { endAngle = newValue }
    }
    
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
        // SwiftUIのPathは「右=0°、反時計回りが正」。12時は -90°
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
    @State var isSnapToMinute = false
    
    var body: some View {
        DraggableClock(
            angle: $angle,
            isEditing: $isEditing,
            isSnapToMinute: $isSnapToMinute,
            effectTimeColor: Color.blue.opacity(0.28)
        )
    }
}

#Preview {
    PreviewContent()
}
#endif

