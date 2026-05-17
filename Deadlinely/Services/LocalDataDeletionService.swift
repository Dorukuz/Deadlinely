import Foundation
import SwiftData

enum LocalDataDeletionService {
    @MainActor
    static func deleteAll(modelContext: ModelContext) async throws {
        let items = try modelContext.fetch(FetchDescriptor<DeadlineItem>())
        for item in items {
            await NotificationService.shared.removeReminders(for: item.id)
            modelContext.delete(item)
        }
        try modelContext.save()

        ModelContainerFactory.sharedDefaults?
            .removeObject(forKey: AppConstants.widgetPinnedDeadlineKey)

        WidgetRefresh.reloadCountdowns()
        resetOnboardingState()
    }

    /// Clears first-run flags so the user sees onboarding again (Settings → Delete local data).
    static func resetOnboardingState() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: AppConstants.hasCompletedOnboardingKey)
        defaults.set(false, forKey: AppConstants.hasShownPostOnboardingPaywallKey)
        defaults.set(false, forKey: AppConstants.hasShownWidgetTutorialKey)
        defaults.set(false, forKey: AppConstants.hasShownProWelcomeKey)
        RevenueCatService.shared.acknowledgeProWelcome()
        SecretOfferStore.reset()
        AppReviewService.reset()
    }
}
