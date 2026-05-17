import RevenueCat
import SwiftUI

// MARK: - Palette

enum SecretOfferStyle {
    static let navy = Color(red: 0.12, green: 0.16, blue: 0.23)
    static let grey = Color(red: 0.39, green: 0.45, blue: 0.55)
    static let purple = Color(red: 0.55, green: 0.36, blue: 0.96)
    static let purpleDeep = Color(red: 0.45, green: 0.28, blue: 0.88)
    static let purpleSoft = Color(red: 0.93, green: 0.91, blue: 1.0)
    static let purpleMist = Color(red: 0.96, green: 0.94, blue: 1.0)
    static let cardShadow = Color.black.opacity(0.08)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.95, blue: 1.0),
                Color(red: 0.94, green: 0.92, blue: 0.99),
                Color(red: 0.91, green: 0.89, blue: 0.98),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var ctaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.55, green: 0.36, blue: 0.96),
                Color(red: 0.39, green: 0.40, blue: 0.95),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct SecretOfferReferenceBackground: View {
    var body: some View {
        SecretOfferStyle.backgroundGradient
            .ignoresSafeArea()
    }
}

// MARK: - Header

struct SecretOfferReferenceHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                Text("SECRET OFFER")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(1.0)
            }
            .foregroundStyle(SecretOfferStyle.purple)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(SecretOfferStyle.purpleSoft))

            Text("A quiet welcome from Finn")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(SecretOfferStyle.navy)
                .multilineTextAlignment(.center)

            Text("You almost missed this one-time monthly price. Same Pro features, less for your first month.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(SecretOfferStyle.grey)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SecretOfferFinnScene: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            SecretOfferStyle.purple.opacity(0.18),
                            SecretOfferStyle.purple.opacity(0.06),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 300, height: 90)
                .offset(y: 24)

            Ellipse()
                .fill(SecretOfferStyle.purple.opacity(0.12))
                .frame(width: 180, height: 56)
                .offset(x: -90, y: 32)

            Ellipse()
                .fill(SecretOfferStyle.purple.opacity(0.1))
                .frame(width: 140, height: 48)
                .offset(x: 100, y: 36)

            FinnAvatar(pose: .wave, size: 130)
                .offset(y: -8)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Offer card

struct SecretOfferReferenceCard: View {
    let offerPackage: Package
    let listPackage: Package?
    let expiresAt: Date
    var usesIntroductoryOffer: Bool = false
    var introEligible: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader
            pricingBlock
            discountPill
            VStack(alignment: .leading, spacing: 14) {
                SecretOfferFeatureRow(icon: "infinity", text: "Unlimited deadlines from day one")
                SecretOfferFeatureRow(icon: "chart.bar.fill", text: "Every deadline, one calm view")
                SecretOfferFeatureRow(icon: "lock.shield.fill", text: "Your data stays on your device")
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: SecretOfferStyle.cardShadow, radius: 16, y: 6)
        )
    }

    private var cardHeader: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let remaining = max(0, Int(expiresAt.timeIntervalSince(context.date).rounded(.down)))

            HStack {
                Text("FIRST MONTH")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(SecretOfferStyle.purple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(SecretOfferStyle.purpleSoft))

                Spacer(minLength: 8)

                HStack(spacing: 5) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Ends in \(SecretOfferStore.formattedCountdown(seconds: remaining))")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                }
                .foregroundStyle(SecretOfferStyle.purple)
            }
            .onChange(of: remaining) { _, newValue in
                if newValue == 0 { SecretOfferStore.markFinished() }
            }
        }
    }

    private var pricingBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text("Usually")
                    .foregroundStyle(SecretOfferStyle.grey)
                if let listPackage {
                    Text(listPackage.storeProduct.localizedPriceString)
                        .strikethrough(true, color: SecretOfferStyle.grey)
                        .foregroundStyle(SecretOfferStyle.grey)
                }
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(offerPriceText)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(SecretOfferStyle.purple)
                Text("first month")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(SecretOfferStyle.purple.opacity(0.85))
            }
        }
    }

    private var discountPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "tag.fill")
                .font(.system(size: 14, weight: .semibold))
            Text(savingsLabel)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(SecretOfferStyle.purpleDeep)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(SecretOfferStyle.purpleSoft)
        )
    }

    private var offerPriceText: String {
        PaywallPricing.secretOfferPriceText(
            for: offerPackage,
            introEligible: usesIntroductoryOffer && introEligible
        )
    }

    private var savingsLabel: String {
        if let listPackage,
           let percent = PaywallPricing.monthlySavingsPercent(
               secret: offerPackage,
               standard: listPackage,
               introEligible: usesIntroductoryOffer && introEligible
           ) {
            return "About \(percent)% off vs. list monthly"
        }
        return "Welcome monthly price"
    }
}

struct SecretOfferUnavailableCard: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "tag.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(SecretOfferStyle.purple)

            Text("Welcome price unavailable")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(SecretOfferStyle.navy)

            Text("Set up Deadlinely Pro Secret in App Store Connect and the discount offering in RevenueCat, then try again.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(SecretOfferStyle.grey)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Button(action: onRetry) {
                Text("Try again")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(SecretOfferStyle.purple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(SecretOfferStyle.purpleSoft)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: SecretOfferStyle.cardShadow, radius: 16, y: 6)
        )
    }
}

struct SecretOfferFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(SecretOfferStyle.purple)
                .frame(width: 22)

            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(SecretOfferStyle.navy)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Footer

struct SecretOfferRenewalNote: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(SecretOfferStyle.purple.opacity(0.7))
            Text("After the first month, Pro renews at the regular monthly price until you cancel in Settings.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(SecretOfferStyle.grey)
                .lineSpacing(2)
        }
    }
}

struct SecretOfferGradientCTA: View {
    var title: String = "CLAIM WELCOME PRICE"
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(SecretOfferStyle.ctaGradient)
                    .shadow(color: SecretOfferStyle.purple.opacity(0.35), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.55 : 1)
        .accessibilityIdentifier(AccessibilityID.paywallPurchase)
    }
}

struct SecretOfferCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(SecretOfferStyle.grey)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: SecretOfferStyle.cardShadow, radius: 4, y: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
        .accessibilityIdentifier(AccessibilityID.secretOfferDismiss)
    }
}
