import RevenueCat
import SwiftUI

// MARK: - Palette (reference mockup)

enum PaywallStyle {
    static let navy = Color(red: 0.10, green: 0.11, blue: 0.18)
    static let grey = Color(red: 0.49, green: 0.52, blue: 0.57)
    static let purple = Color(red: 0.39, green: 0.40, blue: 0.95)
    static let purpleSoft = Color(red: 0.94, green: 0.94, blue: 1.0)
    static let green = Color(red: 0.40, green: 0.73, blue: 0.42)
    static let greenSoft = Color(red: 0.91, green: 0.97, blue: 0.84)
    static let surface = Color(red: 0.97, green: 0.98, blue: 0.99)
    static let cardShadow = Color.black.opacity(0.06)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.98, blue: 1.0),
                Color(red: 0.94, green: 0.96, blue: 0.99),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var selectedPlanGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.45, green: 0.44, blue: 0.98),
                Color(red: 0.39, green: 0.40, blue: 0.95),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Background

struct PaywallReferenceBackground: View {
    var body: some View {
        PaywallStyle.backgroundGradient
            .ignoresSafeArea()
    }
}

// MARK: - Hero

struct PaywallReferenceHero: View {
    var body: some View {
        VStack(spacing: 10) {
            FinnAvatar(pose: .celebrate, size: 88)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("Never miss go-time")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(PaywallStyle.navy)
                .multilineTextAlignment(.center)

            Text("Unlimited deadlines, widget & reminders.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(PaywallStyle.grey)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Feature grid

struct PaywallReferenceFeatureGrid: View {
    private struct Item {
        let icon: String
        let tint: Color
        let title: String
        let subtitle: String
    }

    private let items: [Item] = [
        Item(icon: "infinity", tint: Color.duoBlue, title: "Unlimited", subtitle: "Deadlines"),
        Item(icon: "square.grid.2x2.fill", tint: Color.duoYellow, title: "Widget", subtitle: "Home Screen"),
        Item(icon: "bell.fill", tint: Color.duoPurple, title: "Reminders", subtitle: "Smart Alerts"),
        Item(icon: "paintpalette.fill", tint: Color.duoRed, title: "Urgency", subtitle: "Priority Focus"),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                VStack(spacing: 6) {
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(item.tint)
                        .frame(height: 22)

                    VStack(spacing: 2) {
                        Text(item.title)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(PaywallStyle.navy)
                        Text(item.subtitle)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(PaywallStyle.grey)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: PaywallStyle.cardShadow, radius: 8, y: 3)
                )
            }
        }
    }
}

// MARK: - Plan card

struct PaywallReferencePlanCard: View {
    let package: Package
    let isSelected: Bool
    let monthlyPackage: Package?
    let action: () -> Void

    private var isYearly: Bool { package.packageType == .annual }

    private var accentColor: Color {
        isYearly ? PaywallStyle.purple : PaywallStyle.green
    }

    private var topBadge: (text: String, background: Color, foreground: Color)? {
        if isYearly {
            return ("BEST VALUE", PaywallStyle.purple, .white)
        }
        if package.packageType == .monthly {
            return ("FLEXIBLE", PaywallStyle.greenSoft, PaywallStyle.green)
        }
        return nil
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                cardContent
                    .padding(.top, topBadge == nil ? 0 : 8)

                if let topBadge {
                    Text(topBadge.text)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(topBadge.foreground)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(topBadge.background)
                        )
                        .padding(.leading, 14)
                        .offset(y: -10)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isSelected)
    }

    private var cardContent: some View {
        HStack(alignment: .center, spacing: 10) {
            radioControl

            VStack(alignment: .leading, spacing: 5) {
                Text(package.paywallTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(PaywallStyle.navy)

                if isYearly, package.paywallHasFreeTrial {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                        Text("Free for 3 days")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(PaywallStyle.purple)
                }

                priceLines
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .overlay(cardBorder)
    }

    private var radioControl: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? accentColor : Color(red: 0.82, green: 0.84, blue: 0.88), lineWidth: 2)
                .frame(width: 24, height: 24)
            if isSelected {
                Circle()
                    .fill(accentColor)
                    .frame(width: 14, height: 14)
            }
        }
    }

    @ViewBuilder
    private var priceLines: some View {
        if isYearly {
            if package.paywallHasFreeTrial {
                Text("Then \(package.storeProduct.localizedPriceString) / yr")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(PaywallStyle.grey)
            } else {
                Text(package.storeProduct.localizedPriceString + " / year")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(PaywallStyle.grey)
            }
        } else {
            Text(package.storeProduct.localizedPriceString + " / month")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(PaywallStyle.grey)
            Text("Cancel anytime")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(PaywallStyle.grey)
        }
    }

    @ViewBuilder
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(isSelected && isYearly ? PaywallStyle.purpleSoft : Color.white)
            .shadow(color: isSelected ? .clear : PaywallStyle.cardShadow, radius: 6, y: 2)
    }

    @ViewBuilder
    private var cardBorder: some View {
        if isSelected && isYearly {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(PaywallStyle.selectedPlanGradient, lineWidth: 2.5)
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    isSelected ? accentColor.opacity(0.5) : Color(red: 0.88, green: 0.90, blue: 0.93),
                    lineWidth: isSelected ? 2 : 1
                )
        }
    }
}

// MARK: - Trust bar

struct PaywallReferenceTrustBar: View {
    var body: some View {
        HStack(spacing: 0) {
            trustItem(
                icon: "lock.fill",
                tint: PaywallStyle.green,
                title: "Secure",
                subtitle: "Your data is safe"
            )
            divider
            trustItem(
                icon: "arrow.clockwise",
                tint: Color.duoBlue,
                title: "Cancel anytime",
                subtitle: "No questions asked"
            )
            divider
            trustItem(
                icon: "bolt.fill",
                tint: Color.duoYellow,
                title: "Instant access",
                subtitle: "Start right away"
            )
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.94, green: 0.95, blue: 0.97))
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(red: 0.85, green: 0.87, blue: 0.90))
            .frame(width: 1, height: 36)
    }

    private func trustItem(icon: String, tint: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(PaywallStyle.navy)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(subtitle)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(PaywallStyle.grey)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }
}

// MARK: - CTA & footer

struct PaywallReferenceCTA: View {
    let title: String
    var isLoading: Bool
    var isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .tracking(0.8)
                    if title.contains("FREE TRIAL") {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .heavy))
                    }
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(PaywallStyle.green)
                    .shadow(color: PaywallStyle.green.opacity(0.35), radius: 0, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.55 : 1)
        .accessibilityIdentifier(AccessibilityID.paywallPurchase)
    }
}

struct PaywallReferenceFooter: View {
    let onRestore: () -> Void
    var isLoading: Bool

    var body: some View {
        HStack {
            Button(action: onRestore) {
                Text("Restore")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(PaywallStyle.navy)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            Spacer(minLength: 8)

            Text("Auto-renews · Cancel in Settings")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(PaywallStyle.grey)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

struct PaywallReferenceCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(PaywallStyle.grey)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: PaywallStyle.cardShadow, radius: 4, y: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
}
