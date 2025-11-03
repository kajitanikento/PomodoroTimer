//
//  GifImage.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import SwiftUI

struct GifImage: View {
    
    private var asset: GifAssetProtocol
    @State private var image: Image?
    
    init(_ asset: GifAssetProtocol) {
        self.asset = asset
    }
    
    var body: some View {
        content
            .onAppear {
                Task {
                    image = await asset.gifImage()
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        if let image {
            image
        } else {
            DummyView()
        }
    }
}
