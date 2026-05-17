import RevenueCat
import SwiftUI

struct PaywallView: View {
    @Binding var isPresented: Bool
    var onClosedWithoutPurchase: (() -> Void)? = nil
    var onDismiss: ((_ purchasedThisSession: Bool) -> Void)? = nil

    @Bindable private var revenueCat = RevenueCatService.shared
    @State private var selectedPackage: Package?
    @State private var purchaseCompletedThisSession = false

    private var packages: [Package] {
        PaywallPricing.sortedPlans(revenueCat.standardPackages)
    }

    private var monthlyPackage: Package? {
        packages.first(where: { $0.packageType == .monthly })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaywallReferenceBackground()

                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        PaywallReferenceHero()
                        PaywallReferenceFeatureGrid()
                        plansSection
                        PaywallReferenceTrustBar()

                        if let error = revenueCat.lastError {
                            Text(error)
                                .font(AppFont.caption())
                                .foregroundStyle(Color.duoRed)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }

                        Spacer(minLength: 0)
                    }
                    .contentWidth()
                    .padding(.top, 4)

                    VStack(spacing: 10) {
                        PaywallReferenceCTA(
                            title: primaryCTATitle,
                            isLoading: revenueCat.isLoading,
                            isDisabled: selectedPackage == nil,
                            action: { Task { await purchase() } }
                        )

                        PaywallReferenceFooter(
                            onRestore: {
                                Task {
                                    await revenueCat.restore()
                                    if revenueCat.isPro {
                                        purchaseCompletedThisSession = true
                                        isPresented = false
                                    }
                                }
                            },
                            isLoading: revenueCat.isLoading
                        )
                    }
                    .contentWidth()
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(
                        PaywallStyle.surface.opacity(0.92)
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
            .navigationTitle("Deadlinely Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PaywallReferenceCloseButton {
                        dismissPaywall()
                    }
                    .modifier(OptionalAccessibilityIdentifier(identifier: AccessibilityID.paywallDismiss))
                }
            }
        }
        .preferredColorScheme(.light)
        .interactiveDismissDisabled(revenueCat.isLoading)
        .task {
            purchaseCompletedThisSession = false
            await loadOfferings()
        }
        .onChange(of: isPresented) { wasPresented, isPresentedNow in
            guard wasPresented, !isPresentedNow else { return }
            let purchased = purchaseCompletedThisSession || revenueCat.isPro
            if !purchased {
                onClosedWithoutPurchase?()
            }
            onDismiss?(purchased)
        }
        .onChange(of: revenueCat.isPro) { _, isPro in
            guard isPro, isPresented else { return }
            purchaseCompletedThisSession = true
            isPresented = false
        }
        #if DEBUG
        .screenshotSignalsReady(
            forModes: "paywall",
            minSettle: 1.2,
            afterFinnExtra: 1.4,
            maxFinnWait: 8
        )
        #endif
    }

    // MARK: - Plans

    @ViewBuilder
    private var plansSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CHOOSE YOUR PLAN")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(1.0)
                .foregroundStyle(PaywallStyle.grey)
                .padding(.leading, 2)

            if revenueCat.isLoading && packages.isEmpty {
                PaywallPlanSkeleton(compact: true)
            } else if packages.isEmpty {
                emptyPlansCard
            } else {
                VStack(spacing: 10) {
                    ForEach(packages, id: \.identifier) { package in
                        PaywallReferencePlanCard(
                            package: package,
                            isSelected: selectedPackage?.identifier == package.identifier,
                            monthlyPackage: monthlyPackage
                        ) {
                            Haptic.light()
                            selectedPackage = package
                        }
                    }
                }
            }
        }
    }

    private var emptyPlansCard: some View {
        VStack(spacing: 8) {
            Text("Plans couldn't load.")
                .font(AppFont.body(14))
                .foregroundStyle(PaywallStyle.navy)
            Button("Try again") {
                Task { await loadOfferings() }
            }
            .buttonStyle(DuoSecondaryButtonStyle(tint: .duoBlue, height: 40))
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white))
    }

    private var primaryCTATitle: String {
        guard let selectedPackage else { return "CONTINUE" }
        if selectedPackage.paywallHasFreeTrial {
            return "START FREE TRIAL"
        }
        return "CONTINUE"
    }

    // MARK: - Actions

    private func loadOfferings() async {
        await revenueCat.refreshOfferings()
        if selectedPackage == nil {
            selectedPackage = PaywallPricing.defaultSelection(in: packages)
        }
    }

    private func purchase() async {
        guard let selectedPackage else { return }
        Haptic.medium()
        let success = await revenueCat.purchaseStandard(package: selectedPackage)
        if success {
            Haptic.success()
            purchaseCompletedThisSession = true
            isPresented = false
        }
    }

    private func dismissPaywall() {
        guard !revenueCat.isLoading else { return }
        isPresented = false
    }
}
