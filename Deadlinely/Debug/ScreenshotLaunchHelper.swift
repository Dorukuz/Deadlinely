#if DEBUG
import Foundation
import SwiftData

/// Launch with `-ScreenshotMode=<name>` to seed UI state for App Store captures.
/// Example: `xcrun simctl launch booted Deadlinely.Deadlinely -ScreenshotMode=home-active`
enum ScreenshotLaunchHelper {
    static let modePrefix = "-ScreenshotMode="
    static let forcePaywallKey = "screenshot_forcePaywall"
    static let forceSecretOfferKey = "screenshot_forceSecretOffer"
    static let forceProWelcomeKey = "screenshot_forceProWelcome"
    static let forceWidgetTutorialKey = "screenshot_forceWidgetTutorial"
    static let forceEditorKey = "screenshot_forceEditor"
    static let onboardingStepKey = "screenshot_onboardingStep"

    static var activeMode: String? {
        ProcessInfo.processInfo.arguments
            .first { $0.hasPrefix(modePrefix) }?
            .replacingOccurrences(of: modePrefix, with: "")
    }

    @MainActor
    static func configureIfNeeded(modelContext: ModelContext) {
        guard let mode = activeMode else { return }

        ScreenshotReadyReporter.reset()
        clearScreenshotFlags()
        resetStore(modelContext: modelContext)

        switch mode {
        case "onboarding-welcome":
            setOnboardingIncomplete()
            UserDefaults.standard.set(0, forKey: onboardingStepKey)

        case "onboarding-deadline":
            setOnboardingIncomplete()
            UserDefaults.standard.set(2, forKey: onboardingStepKey)
            UserDefaults.standard.set("Final Exam", forKey: "screenshot_onboardingTitle1")

        case "home-active":
            finishOnboardingFlags()
            seedActiveHomeDeadlines(modelContext: modelContext)

        case "home-completed":
            finishOnboardingFlags()
            seedActiveAndCompletedDeadlines(modelContext: modelContext)

        case "home-empty":
            finishOnboardingFlags()

        case "paywall":
            finishOnboardingFlags()
            UserDefaults.standard.set(false, forKey: AppConstants.hasShownPostOnboardingPaywallKey)
            UserDefaults.standard.set(true, forKey: forcePaywallKey)

        case "secret-offer":
            finishOnboardingFlags()
            UserDefaults.standard.set(true, forKey: AppConstants.hasShownPostOnboardingPaywallKey)
            SecretOfferStore.activateFiveMinuteWindow()
            UserDefaults.standard.set(true, forKey: forceSecretOfferKey)

        case "pro-welcome":
            finishOnboardingFlags()
            UserDefaults.standard.set(false, forKey: AppConstants.hasShownProWelcomeKey)
            RevenueCatService.shared.applyCustomerInfoForScreenshotPreview()
            UserDefaults.standard.set(true, forKey: forceProWelcomeKey)

        case "widget-tutorial":
            finishOnboardingFlags()
            UserDefaults.standard.set(false, forKey: AppConstants.hasShownWidgetTutorialKey)
            UserDefaults.standard.set(true, forKey: forceWidgetTutorialKey)
            seedActiveHomeDeadlines(modelContext: modelContext)

        case "editor":
            finishOnboardingFlags()
            let items = seedActiveHomeDeadlines(modelContext: modelContext)
            if let first = items.first {
                UserDefaults.standard.set(first.id.uuidString, forKey: "screenshot_editorDeadlineID")
            }
            UserDefaults.standard.set(true, forKey: forceEditorKey)

        case "settings":
            finishOnboardingFlags()
            seedActiveHomeDeadlines(modelContext: modelContext)
            UserDefaults.standard.set(true, forKey: "screenshot_forceSettings")

        default:
            break
        }

        try? modelContext.save()
    }

    static func consumeOnboardingStep() -> Int? {
        let step = UserDefaults.standard.integer(forKey: onboardingStepKey)
        guard activeMode != nil, UserDefaults.standard.object(forKey: onboardingStepKey) != nil else {
            return nil
        }
        return step
    }

    static func clearScreenshotFlags() {
        let keys = [
            forcePaywallKey,
            forceSecretOfferKey,
            forceProWelcomeKey,
            forceWidgetTutorialKey,
            forceEditorKey,
            onboardingStepKey,
            "screenshot_editorDeadlineID",
            "screenshot_forceSettings",
            "screenshot_onboardingTitle1",
        ]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }

    @MainActor
    private static func resetStore(modelContext: ModelContext) {
        let items = (try? modelContext.fetch(FetchDescriptor<DeadlineItem>())) ?? []
        items.forEach { modelContext.delete($0) }
    }

    private static func setOnboardingIncomplete() {
        UserDefaults.standard.set(false, forKey: AppConstants.hasCompletedOnboardingKey)
        UserDefaults.standard.set(false, forKey: AppConstants.hasShownPostOnboardingPaywallKey)
        UserDefaults.standard.set(false, forKey: AppConstants.hasShownWidgetTutorialKey)
    }

    private static func finishOnboardingFlags() {
        UserDefaults.standard.set(true, forKey: AppConstants.hasCompletedOnboardingKey)
        UserDefaults.standard.set(true, forKey: AppConstants.hasShownPostOnboardingPaywallKey)
        UserDefaults.standard.set(true, forKey: AppConstants.hasShownWidgetTutorialKey)
        UserDefaults.standard.set(true, forKey: AppConstants.hasShownProWelcomeKey)
    }

    @MainActor
    @discardableResult
    private static func seedActiveHomeDeadlines(modelContext: ModelContext) -> [DeadlineItem] {
        let now = Date()
        let items = [
            DeadlineItem(
                title: "Final Exam",
                targetDate: now.addingTimeInterval(86_400 * 14 + 3_600 * 5),
                reminderDayBefore: true,
                reminderMorningOf: true
            ),
            DeadlineItem(
                title: "Capstone Due",
                targetDate: now.addingTimeInterval(86_400 * 2 + 3_600 * 8),
                reminderDayBefore: true,
                reminderMorningOf: true
            ),
            DeadlineItem(
                title: "Portfolio Review",
                targetDate: now.addingTimeInterval(86_400 * 45),
                reminderDayBefore: true,
                reminderMorningOf: true
            ),
        ]
        items.forEach { modelContext.insert($0) }
        return items
    }

    @MainActor
    private static func seedActiveAndCompletedDeadlines(modelContext: ModelContext) {
        let active = seedActiveHomeDeadlines(modelContext: modelContext)
        let done = DeadlineItem(
            title: "Midterm Essay",
            targetDate: Date().addingTimeInterval(-86_400 * 3),
            isDone: true,
            completedAt: Date().addingTimeInterval(-86_400)
        )
        modelContext.insert(done)
        _ = active
    }
}
#endif
