import AVFoundation
import CoreImage
import CoreVideo
import SwiftUI
import UIKit

extension Notification.Name {
    static let finnFrameAnimationReady = Notification.Name("finnFrameAnimationReady")
}

/// Plays a looping mascot animation by streaming pre-decoded frames onto a
/// `CALayer`. Avoids `AVPlayerLayer`'s live HEVC-alpha path (bluish tint on device).
struct FrameAnimationPlayer: UIViewRepresentable {
    let url: URL
    var targetPixelSize: CGFloat = 540
    var fallbackFPS: Double = 30
    var onFirstFrameDisplayed: (() -> Void)?

    func makeUIView(context: Context) -> FrameAnimationUIView {
        let view = FrameAnimationUIView()
        view.onFirstFrameDisplayed = onFirstFrameDisplayed
        view.configure(url: url, targetPixelSize: targetPixelSize, fallbackFPS: fallbackFPS)
        return view
    }

    func updateUIView(_ view: FrameAnimationUIView, context: Context) {
        view.onFirstFrameDisplayed = onFirstFrameDisplayed
        view.configure(url: url, targetPixelSize: targetPixelSize, fallbackFPS: fallbackFPS)
    }

    static func dismantleUIView(_ view: FrameAnimationUIView, coordinator: ()) {
        view.stop()
    }
}

final class FrameAnimationUIView: UIView {
    var onFirstFrameDisplayed: (() -> Void)?

    private let frameLayer = CALayer()
    private var displayLink: CADisplayLink?
    private var frames: [CGImage] = []
    private var fps: Double = 30
    private var startTime: CFTimeInterval = 0
    private var currentURL: URL?
    private var loadTask: Task<Void, Never>?
    private var didReportFirstFrame = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isOpaque = false
        clipsToBounds = true
        backgroundColor = .clear
        layer.isOpaque = false
        layer.backgroundColor = UIColor.clear.cgColor

        frameLayer.contentsGravity = .resizeAspect
        frameLayer.backgroundColor = UIColor.clear.cgColor
        frameLayer.isOpaque = false
        frameLayer.allowsEdgeAntialiasing = true
        frameLayer.magnificationFilter = .trilinear
        frameLayer.minificationFilter = .trilinear
        layer.addSublayer(frameLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frameLayer.frame = bounds
    }

    func configure(url: URL, targetPixelSize: CGFloat, fallbackFPS: Double) {
        if currentURL == url, frames.isEmpty == false {
            ensureDisplayLink()
            return
        }

        stop()
        currentURL = url

        if let cached = FinnFrameCache.shared.entry(for: url) {
            apply(frames: cached.frames, fps: cached.fps)
            return
        }

        loadTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let result = await FrameExtractor.extract(
                url: url,
                targetPixelSize: targetPixelSize,
                fallbackFPS: fallbackFPS
            ) else { return }

            if Task.isCancelled { return }

            await MainActor.run { [weak self] in
                guard let self else { return }
                guard self.currentURL == url else { return }
                FinnFrameCache.shared.store(url: url, frames: result.frames, fps: result.fps)
                self.apply(frames: result.frames, fps: result.fps)
            }
        }
    }

    func stop() {
        loadTask?.cancel()
        loadTask = nil
        displayLink?.invalidate()
        displayLink = nil
        frames = []
        currentURL = nil
        frameLayer.contents = nil
        didReportFirstFrame = false
    }

    private func apply(frames: [CGImage], fps: Double) {
        self.frames = frames
        self.fps = fps
        self.startTime = CACurrentMediaTime()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        frameLayer.contents = frames.first
        CATransaction.commit()
        ensureDisplayLink()
        reportFirstFrameIfNeeded()
    }

    private func reportFirstFrameIfNeeded() {
        guard didReportFirstFrame == false else { return }
        didReportFirstFrame = true
        onFirstFrameDisplayed?()
        NotificationCenter.default.post(name: .finnFrameAnimationReady, object: nil)
    }

    private func ensureDisplayLink() {
        guard displayLink == nil, frames.isEmpty == false else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 24, maximum: 120, preferred: 60)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc private func tick() {
        guard frames.isEmpty == false else { return }
        let elapsed = CACurrentMediaTime() - startTime
        let frameIndex = Int(elapsed * fps) % frames.count
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        frameLayer.contents = frames[frameIndex]
        CATransaction.commit()
    }
}

@MainActor
final class FinnFrameCache {
    struct Entry {
        var frames: [CGImage]
        var fps: Double
        var lastUsed: CFTimeInterval
    }

    static let shared = FinnFrameCache()
    private var entries: [URL: Entry] = [:]
    private let maxEntries = 3

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryPressure),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    func entry(for url: URL) -> Entry? {
        guard var entry = entries[url] else { return nil }
        entry.lastUsed = CACurrentMediaTime()
        entries[url] = entry
        return entry
    }

    func store(url: URL, frames: [CGImage], fps: Double) {
        entries[url] = Entry(frames: frames, fps: fps, lastUsed: CACurrentMediaTime())
        evictIfNeeded()
    }

    private func evictIfNeeded() {
        guard entries.count > maxEntries else { return }
        let sorted = entries.sorted { $0.value.lastUsed < $1.value.lastUsed }
        for (key, _) in sorted.prefix(entries.count - maxEntries) {
            entries.removeValue(forKey: key)
        }
    }

    @objc private func handleMemoryPressure() {
        entries.removeAll()
    }
}

enum FrameExtractor {
    struct Result {
        let frames: [CGImage]
        let fps: Double
    }

    private static let ciContext: CIContext = {
        let space = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        return CIContext(options: [
            .workingColorSpace: space,
            .outputColorSpace: space,
            .useSoftwareRenderer: false
        ])
    }()

    static func extract(url: URL, targetPixelSize: CGFloat, fallbackFPS: Double) async -> Result? {
        let asset = AVURLAsset(url: url)

        do {
            let tracks = try await asset.loadTracks(withMediaType: .video)
            guard let track = tracks.first else { return nil }

            async let nominalFrameRateAsync = track.load(.nominalFrameRate)
            async let naturalSizeAsync = track.load(.naturalSize)
            async let preferredTransformAsync = track.load(.preferredTransform)

            let nominalFrameRate = try await nominalFrameRateAsync
            let naturalSize = try await naturalSizeAsync
            let preferredTransform = try await preferredTransformAsync

            let transformed = naturalSize.applying(preferredTransform)
            let absoluteSize = CGSize(width: abs(transformed.width), height: abs(transformed.height))
            let maxSide = max(absoluteSize.width, absoluteSize.height)
            let scale = maxSide > 0 ? min(1, targetPixelSize / maxSide) : 1
            let outWidth = max(2, Int((absoluteSize.width * scale).rounded()))
            let outHeight = max(2, Int((absoluteSize.height * scale).rounded()))

            let reader = try AVAssetReader(asset: asset)
            let outputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
                kCVPixelBufferWidthKey as String: outWidth,
                kCVPixelBufferHeightKey as String: outHeight,
                kCVPixelBufferIOSurfacePropertiesKey as String: [:] as [String: Any]
            ]
            let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
            output.alwaysCopiesSampleData = false

            guard reader.canAdd(output) else { return nil }
            reader.add(output)

            guard reader.startReading() else { return nil }

            var frames: [CGImage] = []
            frames.reserveCapacity(180)

            while reader.status == .reading {
                if Task.isCancelled {
                    reader.cancelReading()
                    break
                }
                guard let sampleBuffer = output.copyNextSampleBuffer() else { break }
                if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                   let cgImage = makeCGImage(from: pixelBuffer) {
                    frames.append(cgImage)
                }
                CMSampleBufferInvalidate(sampleBuffer)
            }

            if reader.status == .failed { return nil }

            let fps: Double = {
                if nominalFrameRate > 0 { return Double(nominalFrameRate) }
                return fallbackFPS
            }()

            guard frames.isEmpty == false else { return nil }
            return Result(frames: frames, fps: fps)
        } catch {
            return nil
        }
    }

    private static func makeCGImage(from pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
}
