import StoreKit
import SwiftData
import UIKit

enum AppReviewService {
    /// Prompts for an App Store rating once, after the user marks their first deadline done.
    @MainActor
    static func considerPromptAfterDeadlineCompleted(modelContext: ModelContext) {
        let completedCount = completedCount(in: modelContext)
        guard completedCount >= 1 else { return }
        guard !UserDefaults.standard.bool(forKey: AppConstants.hasRequestedAppReviewKey) else { return }

        UserDefaults.standard.set(true, forKey: AppConstants.hasRequestedAppReviewKey)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.85))
            requestReviewInForeground()
        }
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: AppConstants.hasRequestedAppReviewKey)
    }

    private static func completedCount(in modelContext: ModelContext) -> Int {
        let descriptor = FetchDescriptor<DeadlineItem>(predicate: #Predicate { $0.isDone })
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    @MainActor
    private static func requestReviewInForeground() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }
        AppStore.requestReview(in: scene)
    }
}
