import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppConstants.hasCompletedOnboardingKey) private var hasCompletedOnboarding = false
    @AppStorage(AppConstants.hasShownPostOnboardingPaywallKey) private var hasShownPostOnboardingPaywall = false
    @AppStorage(AppConstants.hasShownWidgetTutorialKey) private var hasShownWidgetTutorial = false

    @State private var showPostOnboardingPaywall = false
    @State private var showSecretOffer = false
    @State private var showWidgetTutorial = false
    @Bindable private var revenueCat = RevenueCatService.shared

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView(onFinished: finishOnboarding)
            }
        }
        .deadlinelyLightSurface()
        .fullScreenCover(isPresented: $showPostOnboardingPaywall) {
            PaywallView(
                isPresented: $showPostOnboardingPaywall,
                onClosedWithoutPurchase: nil,
                onDismiss: { purchased in
                    if purchased {
                        presentProWelcomeOrContinue()
                    } else {
                        presentSecretOfferIfEligible()
                    }
                }
            )
            .deadlinelyLightSurface()
        }
        .sheet(isPresented: $showSecretOffer, onDismiss: handleSecretOfferDismissed) {
            SecretOfferView(isPresented: $showSecretOffer)
                .deadlinelyLightSurface()
        }
        .fullScreenCover(isPresented: proWelcomeBinding) {
            ProWelcomeView {
                revenueCat.acknowledgeProWelcome()
                continueAfterProWelcome()
            }
            .deadlinelyLightSurface()
        }
        .fullScreenCover(isPresented: $showWidgetTutorial) {
            WidgetTutorialView(isPresented: $showWidgetTutorial)
                .onDisappear {
                    hasShownWidgetTutorial = true
                }
        }
        .onChange(of: hasCompletedOnboarding) { _, completed in
            if !completed {
                showPostOnboardingPaywall = false
                showSecretOffer = false
                showWidgetTutorial = false
                revenueCat.acknowledgeProWelcome()
            }
        }
        .task {
            #if DEBUG
            applyScreenshotPresentationIfNeeded()
            #endif
        }
    }

    #if DEBUG
    private func applyScreenshotPresentationIfNeeded() {
        guard ScreenshotLaunchHelper.activeMode != nil else { return }

        if UserDefaults.standard.bool(forKey: ScreenshotLaunchHelper.forcePaywallKey) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showPostOnboardingPaywall = true
            }
        }

        if UserDefaults.standard.bool(forKey: ScreenshotLaunchHelper.forceSecretOfferKey) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showSecretOffer = true
            }
        }

        if UserDefaults.standard.bool(forKey: ScreenshotLaunchHelper.forceWidgetTutorialKey) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showWidgetTutorial = true
            }
        }
    }
    #endif

    private var proWelcomeBinding: Binding<Bool> {
        Binding(
            get: { revenueCat.shouldPresentProWelcome },
            set: { isPresented in
                if !isPresented {
                    revenueCat.acknowledgeProWelcome()
                }
            }
        )
    }

    private func finishOnboarding() {
        hasCompletedOnboarding = true
        runPostOnboardingSequence()
    }

    private func runPostOnboardingSequence() {
        if shouldPresentPaywall() {
            hasShownPostOnboardingPaywall = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showPostOnboardingPaywall = true
            }
            return
        }
        runAfterPaywall()
    }

    private func shouldPresentPaywall() -> Bool {
        !hasShownPostOnboardingPaywall && !revenueCat.isPro
    }

    private func runAfterPaywall() {
        if shouldPresentSecretOffer() {
            SecretOfferStore.activateFiveMinuteWindow()
            guard SecretOfferStore.isWindowActive else {
                presentProWelcomeOrContinue()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                showSecretOffer = true
            }
            return
        }
        presentProWelcomeOrContinue()
    }

    private func shouldPresentSecretOffer() -> Bool {
        !revenueCat.isPro
    }

    private func presentSecretOfferIfEligible() {
        runAfterPaywall()
    }

    private func handleSecretOfferDismissed() {
        presentProWelcomeOrContinue()
    }

    private func presentProWelcomeOrContinue() {
        guard !revenueCat.shouldPresentProWelcome else { return }
        continueAfterProWelcome()
    }

    private func continueAfterProWelcome() {
        presentWidgetTutorialIfNeeded()
    }

    private func presentWidgetTutorialIfNeeded() {
        guard !hasShownWidgetTutorial else { return }
        guard hasCompletedOnboarding else { return }
        guard !showPostOnboardingPaywall, !showSecretOffer, !revenueCat.shouldPresentProWelcome else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard !hasShownWidgetTutorial else { return }
            guard !revenueCat.shouldPresentProWelcome else { return }
            showWidgetTutorial = true
        }
    }
}
