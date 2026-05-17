import Foundation

enum AppConstants {
    static let bundleID = "Deadlinely.Deadlinely"
    static let appGroupID = "group.Deadlinely.Deadlinely.shared"
    static let freeDeadlineLimit = 2
    static let proEntitlementID = "pro"
    static let widgetPinnedDeadlineKey = "widgetPinnedDeadlineID"

    /// Main paywall monthly. No introductory offer in App Store Connect.
    static let monthlyProductID = "Deadlinely_Pro_Monthly"

    /// Secret-offer monthly only. Intro for new users. Never shown on the main paywall.
    static let secretOfferMonthlyProductID = "Deadlinely_Pro_Secret"

    static let yearlyProductID = "Deadlinely_Pro_Yearly"

    /// Legacy alias; prefer `yearlyProductID`.
    static let annualProductID = yearlyProductID

    /// RevenueCat offering for the main paywall (full-price monthly + yearly).
    static let standardOfferingID = "default"

    /// RevenueCat offering: `discount` → `$rc_monthly` → `Deadlinely_Pro_Secret`.
    static let secretOfferOfferingID = "discount"

    /// RevenueCat package identifier inside the `discount` offering.
    static let secretOfferPackageIdentifier = "$rc_monthly"

    /// Promotional offer on `monthlyProductID` for lapsed subscribers. Secret sheet only.
    static let secretOfferPromotionalOfferID = "Secret"

    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let hasShownPostOnboardingPaywallKey = "hasShownPostOnboardingPaywall"
    static let hasShownWidgetTutorialKey = "hasShownWidgetTutorial"
    static let hasRequestedAppReviewKey = "hasRequestedAppReview"
    static let hasShownProWelcomeKey = "hasShownProWelcome"
}
