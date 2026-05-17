import SwiftUI

struct DeadlineCardView: View {
    let item: DeadlineItem
    var isNextUp: Bool = false

    var body: some View {
        if item.isDone {
            doneCardContent
        } else {
            TimelineView(.periodic(from: .now, by: tickInterval)) { context in
                let remaining = TimeRemaining(from: item.targetDate, reference: context.date)
                let urgency = Urgency(timeRemaining: item.targetDate.timeIntervalSince(context.date))
                activeCardContent(remaining: remaining, urgency: urgency)
            }
        }
    }

    private var tickInterval: TimeInterval {
        item.timeRemaining.isUnderOneHour ? 1.0 : 60.0
    }

    private var doneCardContent: some View {
        let accent = Color.duoGreen
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(AppFont.title(18))
                        .foregroundStyle(Theme.textSecondary)
                        .strikethrough(true, color: Theme.textSecondary.opacity(0.6))
                        .lineLimit(2)

                    Text(doneSubtitle)
                        .font(AppFont.body(14))
                        .foregroundStyle(Theme.textSecondary)

                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11, weight: .bold))
                        Text(item.targetDate.formatted(date: .abbreviated, time: .shortened))
                    }
                    .font(AppFont.caption())
                    .foregroundStyle(Theme.textSecondary.opacity(0.85))
                }

                Spacer(minLength: 4)

                VStack(alignment: .trailing, spacing: 10) {
                    donePill
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(accent)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.92))
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(accent.opacity(0.5))
                .frame(width: 4)
                .padding(.vertical, 14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(accent.opacity(0.2), lineWidth: Theme.strokeWidth)
        )
    }

    private var doneSubtitle: String {
        if let completedAt = item.completedAt {
            return "Finished \(completedAt.formatted(date: .abbreviated, time: .omitted))"
        }
        return "Marked done"
    }

    private var donePill: some View {
        Text("DONE")
            .font(AppFont.caption())
            .tracking(0.6)
            .foregroundStyle(Color.duoGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.duoGreenSoft))
            .overlay(Capsule().stroke(Color.duoGreen.opacity(0.35), lineWidth: 1))
    }

    private func activeCardContent(remaining: TimeRemaining, urgency: Urgency) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if isNextUp {
                Text("NEXT UP")
                    .font(AppFont.caption())
                    .tracking(1.0)
                    .foregroundStyle(urgency.color)
            }

            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(AppFont.title(18))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(remaining.heroCountdown)
                        .font(.system(size: countdownSize(for: remaining), weight: .heavy, design: .rounded))
                        .foregroundStyle(urgency.color)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11, weight: .bold))
                        Text(item.targetDate.formatted(date: .abbreviated, time: .shortened))
                    }
                    .font(AppFont.caption())
                    .foregroundStyle(Theme.textSecondary)
                }

                Spacer(minLength: 4)

                VStack(alignment: .trailing, spacing: 10) {
                    statusPill(urgency: urgency)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.textSecondary.opacity(0.45))
                }
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
                .padding(.vertical, 14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(urgency.color.opacity(0.28), lineWidth: Theme.strokeWidth)
        )
        .shadow(color: urgency.color.opacity(0.08), radius: 12, y: 4)
    }

    private func countdownSize(for remaining: TimeRemaining) -> CGFloat {
        if remaining.isUnderOneHour { return 36 }
        if remaining.days > 0 { return 40 }
        return 44
    }

    private func statusPill(urgency: Urgency) -> some View {
        Text(urgency.statusLabel)
            .font(AppFont.caption())
            .tracking(0.6)
            .foregroundStyle(urgency.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(urgency.softFill))
            .overlay(Capsule().stroke(urgency.color.opacity(0.35), lineWidth: 1))
    }
}
