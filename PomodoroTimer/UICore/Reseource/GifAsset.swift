//
//  GifAsset.swift
//  PomodoroTimer
//
//  Created by kajitani kento on 2025/11/03.
//

import SwiftUI

protocol GifAssetProtocol {
    var rawValue: String { get }
}

enum GifAsset {
    enum Cat: String, GifAssetProtocol {
        case catOnBall = "CatOnBall"
        case waitCat = "WaitCat"
    }
}

extension GifAssetProtocol {
    func gifImage() async -> Image {
        Image(uiImage: await .gifImage(dataAssetName: "GIF/\(rawValue)")!)
    }
}
