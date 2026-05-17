import SwiftUI

/// Live countdown hero for onboarding step 4; updates every second when under one hour.
struct OnboardingPreviewHeroCard: View {
    let title: String
    let targetDate: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let remaining = TimeRemaining(from: targetDate, reference: context.date)
            let liveUrgency = Urgency(timeRemaining: targetDate.timeIntervalSince(context.date))

            cardContent(remaining: remaining, urgency: liveUrgency)
        }
    }

    private func cardContent(remaining: TimeRemaining, urgency: Urgency) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(displayTitle)
                        .font(AppFont.title(17))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)

                    Text(remaining.heroCountdown)
                        .font(.system(size: heroFontSize(for: remaining), weight: .heavy, design: .rounded))
                        .foregroundStyle(urgency.color)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text(remaining.heroSubtitle)
                        .font(AppFont.body(14))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: 8)
                verdictPill(for: urgency)
            }

            HStack(spacing: 8) {
                featureChip(icon: "lock.square", text: "Lock Screen", tint: .duoBlue)
                featureChip(icon: "paintpalette.fill", text: "Color-coded", tint: .duoYellow)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(urgency.color)
                .frame(width: 4)
                .padding(.vertical, 12)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(urgency.color.opacity(0.35), lineWidth: Theme.strokeWidth)
        )
    }

    private var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Your deadline" : trimmed
    }

    private func heroFontSize(for remaining: TimeRemaining) -> CGFloat {
        if remaining.isUnderOneHour { return 40 }
        if remaining.days > 0 { return 44 }
        return 48
    }

    private func verdictPill(for urgency: Urgency) -> some View {
        Text(urgency.statusLabel)
            .font(AppFont.caption())
            .tracking(0.8)
            .foregroundStyle(urgency.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(urgency.softFill)
            )
            .overlay(
                Capsule().stroke(urgency.color.opacity(0.4), lineWidth: 1)
            )
    }

    private func featureChip(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(tint)
            Text(text)
                .font(AppFont.caption())
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.1))
        )
    }
}
