import RevenueCat
import SwiftUI

struct SecretOfferView: View {
    @Binding var isPresented: Bool
    @Bindable private var revenueCat = RevenueCatService.shared
    @State private var selectedPackage: Package?

    private var expiresAt: Date {
        SecretOfferStore.expiresAt ?? Date()
    }

    private var activeOfferPackage: Package? {
        selectedPackage ?? revenueCat.secretOfferMonthlyPackage
    }

    private var standardMonthly: Package? {
        revenueCat.standardMonthlyPackage
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SecretOfferReferenceBackground()

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 14) {
                            SecretOfferReferenceHeader()
                            SecretOfferFinnScene()

                            if let package = activeOfferPackage {
                                SecretOfferReferenceCard(
                                    offerPackage: package,
                                    listPackage: standardMonthly,
                                    expiresAt: expiresAt,
                                    usesIntroductoryOffer: revenueCat.secretOfferKind(for: package) == .introductory,
                                    introEligible: revenueCat.isWelcomeIntroEligible
                                )
                            } else if revenueCat.isLoading {
                                ProgressView()
                                    .tint(SecretOfferStyle.purple)
                                    .frame(height: 200)
                            } else {
                                SecretOfferUnavailableCard {
                                    Task { await loadOffer() }
                                }
                            }

                            SecretOfferRenewalNote()

                            if let error = revenueCat.lastError {
                                Text(error)
                                    .font(AppFont.caption())
                                    .foregroundStyle(Color.duoRed)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .contentWidth()
                        .padding(.top, 4)
                        .padding(.bottom, 12)
                    }

                    VStack(spacing: 14) {
                        if SecretOfferStore.isWindowActive {
                            SecretOfferGradientCTA(
                                isLoading: revenueCat.isLoading,
                                isDisabled: activeOfferPackage == nil,
                                action: { Task { await purchase() } }
                            )
                        } else {
                            SecretOfferGradientCTA(
                                title: "CONTINUE",
                                isLoading: false,
                                isDisabled: false,
                                action: { closeOffer() }
                            )
                        }

                        Button {
                            Task { await revenueCat.restore() }
                        } label: {
                            Text("Restore Purchases")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(SecretOfferStyle.purple)
                        }
                        .buttonStyle(.plain)
                        .disabled(revenueCat.isLoading)
                    }
                    .contentWidth()
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topLeading) {
                SecretOfferCloseButton(action: closeOffer)
                    .padding(.leading, Theme.horizontalPadding)
                    .padding(.top, 8)
            }
        }
        .preferredColorScheme(.light)
        .interactiveDismissDisabled(revenueCat.isLoading)
        .task { await loadOffer() }
        .onChange(of: revenueCat.isPro) { _, isPro in
            guard isPro, isPresented else { return }
            SecretOfferStore.markFinished()
            isPresented = false
        }
        #if DEBUG
        .screenshotSignalsReady(
            forModes: "secret-offer",
            minSettle: 1.2,
            afterFinnExtra: 1.5,
            maxFinnWait: 8
        )
        #endif
    }

    private func loadOffer() async {
        await revenueCat.refreshSecretOfferState()
        selectedPackage = revenueCat.secretOfferMonthlyPackage
        if !SecretOfferStore.isWindowActive {
            SecretOfferStore.markFinished()
        }
    }

    private func purchase() async {
        guard SecretOfferStore.isWindowActive, let activeOfferPackage else { return }
        Haptic.medium()
        let success = await revenueCat.purchaseSecretOffer(package: activeOfferPackage)
        if success {
            Haptic.success()
            SecretOfferStore.markFinished()
            isPresented = false
        }
    }

    private func closeOffer() {
        SecretOfferStore.markFinished()
        isPresented = false
    }
}
