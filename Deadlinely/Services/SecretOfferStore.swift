import Foundation

/// One-time 5-minute secret offer shown after the user dismisses the post-onboarding paywall.
enum SecretOfferStore {
    private static let expiresAtKey = "secretOfferExpiresAt"
    private static let finishedKey = "secretOfferFlowFinished"

    static let windowDuration: TimeInterval = 5 * 60

    static func activateFiveMinuteWindow() {
        guard !UserDefaults.standard.bool(forKey: finishedKey) else { return }
        UserDefaults.standard.set(Date().addingTimeInterval(windowDuration), forKey: expiresAtKey)
    }

    static var expiresAt: Date? {
        UserDefaults.standard.object(forKey: expiresAtKey) as? Date
    }

    static var isWindowActive: Bool {
        guard let expiresAt, !UserDefaults.standard.bool(forKey: finishedKey) else { return false }
        return Date() < expiresAt
    }

    static var remainingSeconds: Int {
        guard let expiresAt else { return 0 }
        return max(0, Int(expiresAt.timeIntervalSinceNow.rounded(.down)))
    }

    static func markFinished() {
        UserDefaults.standard.set(true, forKey: finishedKey)
        UserDefaults.standard.removeObject(forKey: expiresAtKey)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: finishedKey)
        UserDefaults.standard.removeObject(forKey: expiresAtKey)
    }

    static func formattedCountdown(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
