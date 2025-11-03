//
//  GifImage.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import SwiftUI

struct GifImage: View {
    
    private var asset: GifAssetProtocol
    @State private var gifImage: UIImage?
    
    init(_ asset: GifAssetProtocol) {
        self.asset = asset
    }
    
    var body: some View {
        content
            .onAppear {
                Task {
                    gifImage = await asset.gifImage()
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        if let gifImage {
            GifImageUIViewRepresentable(uiImage: gifImage)
        } else {
            DummyView()
        }
    }
}

private struct GifImageUIViewRepresentable: UIViewRepresentable {
    private let uiImage: UIImage

    init(uiImage: UIImage) {
        self.uiImage = uiImage
    }

    func makeUIView(context _: Context) -> GifImageUIView {
        GifImageUIView()
    }

    func updateUIView(_ imageView: GifImageUIView, context _: Context) {
        imageView.set(uiImage: uiImage)
    }
}

private final class GifImageUIView: UIView {
    private let imageView = UIImageView()

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.frame = bounds
        addSubview(imageView)
    }

    func set(uiImage: UIImage) {
        imageView.image = uiImage
    }
}
