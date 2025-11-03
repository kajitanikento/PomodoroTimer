//
//  CatView.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/04.
//

import SwiftUI

struct CatView: View {
    
    var asset: GifAsset.Cat
    var width: CGFloat
    
    @State var isAnimation = false
    
    init(
        _ asset: GifAsset.Cat,
        width: CGFloat
    ) {
        self.asset = asset
        self.width = width
    }
    
    var body: some View {
        cat
            
    }
    
    @ViewBuilder
    var cat: some View {
        switch asset {
        case .catOnBall:
            catOnBall
        default:
            catGif(asset)
                .onAppear {
                    isAnimation = false
                }
        }
    }
    
    var catOnBall: some View {
        HStack {
            if isAnimation {
                Spacer()
            }
            catGif(.catOnBall)
        }
        .task {
            try? await Task.sleep(for: .seconds(1))
            guard asset == .catOnBall,
                  !isAnimation else { return }
            withAnimation(.easeInOut(duration: 5).repeatForever()) {
                isAnimation = true
            }
        }
    }
    
    func catGif(_ asset: GifAsset.Cat) -> some View {
        GifImage(asset)
            .scaledToFit()
            .frame(width: width)
    }
}
