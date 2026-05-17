import RevenueCat
import SwiftUI

// MARK: - Shared layout

struct PaywallHero: View {
    var pose: FinnPose = .celebrate
    let title: String
    let subtitle: String
    var avatarSize: CGFloat = 140

    var body: some View {
        VStack(spacing: 14) {
            FinnAvatar(pose: pose, size: avatarSize)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(spacing: 8) {
                Text(title)
                    .font(AppFont.headline(28))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(AppFont.body(16))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PaywallBenefitsCard: View {
    var body: some View {
        VStack(spacing: 0) {
            benefitRow(icon: "infinity", tint: Color.duoBlue, title: "Unlimited deadlines", subtitle: "Track every exam and project")
            Divider().overlay(Theme.border)
            benefitRow(icon: "lock.square", tint: Color.duoYellow, title: "Lock Screen widget", subtitle: "Glanceable days and hours")
            Divider().overlay(Theme.border)
            benefitRow(icon: "bell.fill", tint: Color.duoPurple, title: "Smart reminders", subtitle: "Gentle heads-up before go-time")
            Divider().overlay(Theme.border)
            benefitRow(icon: "paintpalette.fill", tint: Color.duoRed, title: "Color-coded urgency", subtitle: "Green, yellow, red as you get closer")
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.border, lineWidth: Theme.strokeWidth)
        )
    }

    private func benefitRow(icon: String, tint: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.12))
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(tint)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.body(16))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(AppFont.caption())
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Compact paywall (no scroll)

struct PaywallCompactHeader: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            FinnAvatar(pose: .celebrate, size: 76)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Never miss go-time")
                    .font(AppFont.headline(22))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                Text("Unlimited deadlines, widget & reminders.")
                    .font(AppFont.body(14))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
    }
}

struct PaywallCompactBenefits: View {
    private let items: [(String, Color, String)] = [
        ("infinity", .duoBlue, "Unlimited"),
        ("lock.square", .duoYellow, "Widget"),
        ("bell.fill", .duoPurple, "Reminders"),
        ("paintpalette.fill", .duoRed, "Urgency"),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.2) { icon, tint, label in
                VStack(spacing: 5) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(tint)
                    Text(label)
                        .font(AppFont.caption())
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.1))
                )
            }
        }
    }
}

struct PaywallPlanCard: View {
    let package: Package
    let isSelected: Bool
    var badge: String?
    var detailLine: String?
    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: compact ? 10 : 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.duoBlue : Theme.border, lineWidth: Theme.strokeWidth)
                        .frame(width: compact ? 22 : 26, height: compact ? 22 : 26)
                    if isSelected {
                        Circle()
                            .fill(Color.duoBlue)
                            .frame(width: compact ? 12 : 14, height: compact ? 12 : 14)
                    }
                }

                VStack(alignment: .leading, spacing: compact ? 2 : 4) {
                    HStack(spacing: 6) {
                        Text(package.paywallTitle)
                            .font(compact ? AppFont.title(16) : AppFont.title(18))
                            .foregroundStyle(Theme.textPrimary)
                        if let badge {
                            Text(badge.uppercased())
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .tracking(0.4)
                                .foregroundStyle(Color.duoGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.duoGreenSoft))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                    }
                    Text(package.paywallPrimaryPriceLine)
                        .font(compact ? AppFont.body(14) : AppFont.body(15))
                        .foregroundStyle(Theme.textPrimary)
                    if let detailLine {
                        Text(detailLine)
                            .font(AppFont.caption())
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(compact ? 1 : 2)
                            .minimumScaleFactor(0.85)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(compact ? 12 : 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                    .fill(isSelected ? Color.duoBlueSoft : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                    .stroke(isSelected ? Color.duoBlue : Theme.border, lineWidth: Theme.strokeWidth)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isSelected)
    }
}

struct PaywallCompactFooter: View {
    let primaryTitle: String
    var isLoading: Bool
    var isDisabled: Bool
    let onPurchase: () -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onPurchase) {
                Group {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(primaryTitle)
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .buttonStyle(DuoButtonStyle(
                tint: .duoGreen,
                shadowTint: .duoGreenShadow,
                disabled: isDisabled || isLoading,
                height: 50
            ))
            .disabled(isDisabled || isLoading)
            .accessibilityIdentifier(AccessibilityID.paywallPurchase)

            HStack(spacing: 16) {
                Button(action: onRestore) {
                    Text("Restore")
                        .font(AppFont.caption())
                        .foregroundStyle(Theme.textPrimary)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                Text("Auto-renews · cancel in Settings")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
    }
}

struct PaywallPlanSkeleton: View {
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 8 : 12) {
            RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                .fill(Theme.border.opacity(0.45))
                .frame(height: compact ? 64 : 88)
            RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                .fill(Theme.border.opacity(0.35))
                .frame(height: compact ? 64 : 88)
        }
    }
}

struct PaywallStickyFooter: View {
    let primaryTitle: String
    var tint: Color = .duoGreen
    var shadowTint: Color = .duoGreenShadow
    var footnote: String?
    var isLoading: Bool
    var isDisabled: Bool
    let onPurchase: () -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider().overlay(Theme.border)

            VStack(spacing: 12) {
                Button(action: onPurchase) {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(primaryTitle)
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                .buttonStyle(DuoButtonStyle(
                    tint: tint,
                    shadowTint: shadowTint,
                    disabled: isDisabled || isLoading,
                    height: 54
                ))
                .disabled(isDisabled || isLoading)
                .accessibilityIdentifier(AccessibilityID.paywallPurchase)

                Button(action: onRestore) {
                    Text("Restore purchases")
                        .font(AppFont.caption())
                        .foregroundStyle(Theme.textPrimary)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                if let footnote {
                    Text(footnote)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }

                Text(PaywallCopy.subscriptionDisclaimer)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, 14)
            .padding(.bottom, 12)
            .background(Theme.background)
        }
    }
}

enum PaywallCopy {
    static let subscriptionDisclaimer =
        "Payment is charged to your Apple ID. Subscriptions renew automatically unless cancelled at least 24 hours before the period ends. Manage in Settings → Apple ID → Subscriptions."

    static let trialDisclaimer =
        "Free trial converts to a paid annual subscription unless you cancel at least 24 hours before the trial ends."
}

// MARK: - Package helpers

extension Package {
    var paywallHasFreeTrial: Bool {
        guard packageType == .annual else { return false }
        guard let intro = storeProduct.introductoryDiscount else { return false }
        return intro.paymentMode == .freeTrial
    }

    var paywallPrimaryPriceLine: String {
        if paywallHasFreeTrial {
            return "Free for 3 days"
        }
        return storeProduct.localizedPriceString + paywallPeriodSuffix
    }

    var paywallTitle: String {
        switch packageType {
        case .annual: "Yearly"
        case .monthly: "Monthly"
        case .weekly: "Weekly"
        case .lifetime: "Lifetime"
        default: storeProduct.localizedTitle
        }
    }

    var paywallPeriodSuffix: String {
        switch packageType {
        case .annual: " / year"
        case .monthly: " / month"
        case .weekly: " / week"
        default: ""
        }
    }
}

enum PaywallPricing {
    static func sortedPlans(_ packages: [Package]) -> [Package] {
        packages.sorted { lhs, rhs in
            rank(lhs.packageType) < rank(rhs.packageType)
        }
    }

    static func defaultSelection(in packages: [Package]) -> Package? {
        packages.first(where: { $0.packageType == .annual })
            ?? packages.first(where: { $0.packageType == .monthly })
            ?? packages.first
    }

    static func compactDetailLine(for package: Package, monthlyPackage: Package?) -> String? {
        switch package.packageType {
        case .annual:
            if package.paywallHasFreeTrial {
                return "Then \(package.storeProduct.localizedPriceString)/yr"
            }
            if let monthlyPackage, let savings = savingsPercent(annual: package, monthly: monthlyPackage) {
                return "Save \(savings)% vs monthly"
            }
            return nil
        case .monthly:
            return "Cancel anytime"
        default:
            return nil
        }
    }

    static func detailLine(for package: Package, monthlyPackage: Package?) -> String? {
        switch package.packageType {
        case .annual:
            if package.paywallHasFreeTrial {
                return "Then \(package.storeProduct.localizedPriceString) / year · cancel anytime"
            }
            if let monthly = monthlyEquivalentPerMonth(for: package) {
                var line = "Just \(monthly) per month"
                if let monthlyPackage, let savings = savingsPercent(annual: package, monthly: monthlyPackage) {
                    line += " · Save \(savings)%"
                }
                return line
            }
            return "Best value for serious students"
        case .monthly:
            return "Cancel anytime"
        default:
            return nil
        }
    }

    static func badge(for package: Package, hasMultiplePlans: Bool) -> String? {
        guard hasMultiplePlans else { return nil }
        if package.packageType == .annual {
            return package.paywallHasFreeTrial ? "3-day free trial" : "Best value"
        }
        if package.packageType == .monthly { return "Flexible" }
        return nil
    }

    static func secretOfferDetailLine(for package: Package, standardMonthly: Package?) -> String? {
        guard package.packageType == .monthly else { return nil }
        var line = "Secret monthly price · cancel anytime"
        if let standardMonthly,
           let savings = monthlySavingsPercent(secret: package, standard: standardMonthly, introEligible: false) {
            line += " · Save \(savings)%"
        }
        return line
    }

    static func monthlySavingsPercent(secret: Package, standard: Package, introEligible: Bool) -> Int? {
        let secretPrice = offerPriceValue(for: secret, introEligible: introEligible)
        let standardPrice = NSDecimalNumber(decimal: standard.storeProduct.price as Decimal).doubleValue
        guard secretPrice > 0, standardPrice > secretPrice else { return nil }
        return Int(((1 - secretPrice / standardPrice) * 100).rounded())
    }

    static func offerPriceValue(for package: Package, introEligible: Bool) -> Double {
        if package.storeProduct.productIdentifier == AppConstants.secretOfferMonthlyProductID,
           introEligible,
           let intro = package.storeProduct.introductoryDiscount {
            return NSDecimalNumber(decimal: intro.price as Decimal).doubleValue
        }
        if let promo = secretOfferDiscount(for: package) {
            return NSDecimalNumber(decimal: promo.price as Decimal).doubleValue
        }
        return NSDecimalNumber(decimal: package.storeProduct.price as Decimal).doubleValue
    }

    static func secretOfferDiscount(for package: Package) -> StoreProductDiscount? {
        package.storeProduct.discounts.first {
            $0.offerIdentifier == AppConstants.secretOfferPromotionalOfferID
        }
    }

    static func secretOfferPriceText(for package: Package, introEligible: Bool) -> String {
        if package.storeProduct.productIdentifier == AppConstants.secretOfferMonthlyProductID,
           introEligible,
           let intro = package.storeProduct.introductoryDiscount {
            return intro.localizedPriceString
        }
        if let promo = secretOfferDiscount(for: package) {
            return promo.localizedPriceString
        }
        return package.storeProduct.localizedPriceString
    }

    private static func rank(_ type: PackageType) -> Int {
        switch type {
        case .annual: 0
        case .monthly: 1
        case .weekly: 2
        case .lifetime: 3
        default: 4
        }
    }

    private static func monthlyEquivalentPerMonth(for annual: Package) -> String? {
        let annualPrice = NSDecimalNumber(decimal: annual.storeProduct.price as Decimal)
        guard annualPrice.doubleValue > 0 else { return nil }
        let perMonth = annualPrice.dividing(by: 12)
        return formatCurrency(perMonth, locale: Locale.current)
    }

    private static func savingsPercent(annual: Package, monthly: Package) -> Int? {
        let annualPrice = NSDecimalNumber(decimal: annual.storeProduct.price as Decimal).doubleValue
        let monthlyPrice = NSDecimalNumber(decimal: monthly.storeProduct.price as Decimal).doubleValue
        guard annualPrice > 0, monthlyPrice > 0 else { return nil }
        let yearlyFromMonthly = monthlyPrice * 12
        let saved = 1 - (annualPrice / yearlyFromMonthly)
        guard saved > 0.05 else { return nil }
        return Int((saved * 100).rounded())
    }

    private static func formatCurrency(_ amount: NSDecimalNumber, locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount) ?? amount.stringValue
    }
}
