//
//  Image+GIF.swift
//  PomodoroTimer
//
//  Created by kento.kajitani on 2025/11/03.
//

import UIKit
import Synchronization

extension UIImage {
    
    static func gifImage(dataAssetName: String) async -> UIImage? {
        guard let data = NSDataAsset(name: dataAssetName)?.data else {
            return nil
        }
        return await gifImage(data: data)
    }
    
    private static func gifImage(data: Data) async -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil)
        else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        let delays = (0 ..< count).map {
            Int(delayForImage(at: $0, source: source) * 1000)
        }
        let duration = delays.reduce(0, +)
        let gcd = delays.reduce(0, gcd)
        let gifFrames: Mutex<[(Int, [UIImage])]> = .init([])

        let context = CIContext()

        @Sendable func preparingImage(
            index: Int
        ) async {
            let uiImage: UIImage? = autoreleasepool {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                    // GifのDataAssetから生成したCGImageにbyPreparingForDisplay()を適応するとデータ欠損のエラーログが吐かれるので、一度CIImageにしてからCGImageを生成しなおす
                    let ciImage = CIImage(cgImage: cgImage)
                    guard let recreateCGImage = context.createCGImage(ciImage, from: .init(x: 0, y: 0, width: cgImage.width, height: cgImage.height)) else {
                        return nil
                    }
                    return UIImage(cgImage: recreateCGImage)
                }
                return nil
            }
            let decodedImage: UIImage? = await uiImage?.byPreparingForDisplay()
            guard let decodedImage else {
                gifFrames.withLock {
                    $0.append((index, []))
                }
                return
            }
            return gifFrames.withLock {
                $0.append((index, Array(repeating: decodedImage, count: delays[index] / gcd)))
            }
        }

        await withTaskGroup(
            of: Void.self
        ) { taskGroup in
            for index in 0 ..< count {
                taskGroup.addTask {
                    await preparingImage(index: index)
                }
            }
            await taskGroup.waitForAll()
        }

        // 並列実行でフレーム順がバラバラなのでソートして正しい順序の画像の配列を生成する
        let sortedGifFrames = gifFrames.withLock {
            $0.sorted { prev, next in prev.0 < next.0 }
                .flatMap { _, images in images }
        }
        
        return UIImage.animatedImage(
            with: sortedGifFrames,
            duration: Double(duration) / 1000.0
        )
    }
    
    private static func gcd(_ a: Int, _ b: Int) -> Int {
        let absB = abs(b)
        let r = abs(a) % absB
        if r != 0 {
            return gcd(absB, r)
        } else {
            return absB
        }
    }

    private static func delayForImage(at index: Int, source: CGImageSource) -> Double {
        let defaultDelay = 1.0

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return defaultDelay
        }
        let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        var delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                              Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                                         to: AnyObject.self)
        if delayWrapper.doubleValue == 0 {
            delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                              Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                                         to: AnyObject.self)
        }

        if let delay = delayWrapper as? Double,
           delay > 0 {
            return delay
        } else {
            return defaultDelay
        }
    }
    
    private struct GifFlame {
        var index: Int
        var image: UIImage
    }
}
