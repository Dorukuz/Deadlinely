#if DEBUG
import Foundation
import os.log

/// Emits `DEADLINELY_SCREENSHOT_READY:<mode>` to the simulator log when the UI is settled.
/// The capture script waits on this instead of a fixed sleep.
enum ScreenshotReadyReporter {
    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Deadlinely", category: "Screenshot")
    private static var didSignal = false

    static func reset() {
        didSignal = false
    }

    /// Waits for several display frames so `simctl io screenshot` captures painted UI, not a white launch window.
    static func signalReady() {
        guard let mode = ScreenshotLaunchHelper.activeMode else { return }
        guard didSignal == false else { return }

        Task { @MainActor in
            for _ in 0 ..< 4 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(250))
            }
            try? await Task.sleep(for: .seconds(1.25))

            guard didSignal == false else { return }
            didSignal = true
            let message = "DEADLINELY_SCREENSHOT_READY:\(mode)"
            log.notice("\(message, privacy: .public)")
            NSLog("%@", message)
        }
    }
}

import SwiftUI

private struct ScreenshotReadyModifier: ViewModifier {
    let allowedModes: Set<String>
    var minSettle: TimeInterval = 0.55
    var afterFinnExtra: TimeInterval = 1.4
    var maxFinnWait: TimeInterval = 7.0

    @State private var finnReady = false

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .finnFrameAnimationReady)) { _ in
                finnReady = true
            }
            .task {
                guard let mode = ScreenshotLaunchHelper.activeMode,
                      allowedModes.contains(mode)
                else { return }
                try? await Task.sleep(for: .seconds(minSettle))

                let deadline = Date().addingTimeInterval(maxFinnWait)
                while finnReady == false, Date() < deadline {
                    try? await Task.sleep(for: .milliseconds(100))
                }

                try? await Task.sleep(for: .seconds(afterFinnExtra + 0.75))
                ScreenshotReadyReporter.signalReady()
            }
    }
}

extension View {
    func screenshotSignalsReady(
        forModes modes: String...,
        minSettle: TimeInterval = 0.55,
        afterFinnExtra: TimeInterval = 1.4,
        maxFinnWait: TimeInterval = 7.0
    ) -> some View {
        modifier(
            ScreenshotReadyModifier(
                allowedModes: Set(modes),
                minSettle: minSettle,
                afterFinnExtra: afterFinnExtra,
                maxFinnWait: maxFinnWait
            )
        )
    }
}
#endif
