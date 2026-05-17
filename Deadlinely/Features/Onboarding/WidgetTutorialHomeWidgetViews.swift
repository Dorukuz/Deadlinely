import SwiftUI

// Mirrors `DeadlineHomeSmallView` / `DeadlineHomeMediumView` in the widget extension.

struct WidgetTutorialWidgetSample {
    let title: String
    let heroText: String
    let dueText: String
    let urgency: Urgency

    static let standard = WidgetTutorialWidgetSample(
        title: "Exam",
        heroText: "13d 23h",
        dueText: "May 31, 2026 at 16:47",
        urgency: .green
    )
}

struct WidgetTutorialRealHomeSmallView: View {
    let sample: WidgetTutorialWidgetSample

    private enum Colors {
        static let textPrimary = Color(red: 0.12, green: 0.14, blue: 0.18)
        static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.52)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(sample.title)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Colors.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                statusPill
            }

            Text(sample.heroText)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(sample.urgency.color)
                .minimumScaleFactor(0.65)
                .lineLimit(1)

            Text(sample.dueText)
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(Colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background { WidgetTutorialHomeWidgetBackground(urgency: sample.urgency) }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var statusPill: some View {
        Text(sample.urgency.statusLabel)
            .font(.system(size: 9, weight: .heavy, design: .rounded))
            .foregroundStyle(sample.urgency.color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(sample.urgency.color.opacity(0.15)))
    }
}

struct WidgetTutorialRealHomeMediumView: View {
    let sample: WidgetTutorialWidgetSample

    private enum Colors {
        static let textPrimary = Color(red: 0.12, green: 0.14, blue: 0.18)
        static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.52)
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("TIME LEFT")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(Colors.textSecondary)

                Text(sample.heroText)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(sample.urgency.color)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(sample.title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Colors.textPrimary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 8) {
                Text(sample.urgency.statusLabel)
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(sample.urgency.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(sample.urgency.color.opacity(0.12)))

                Image(systemName: "calendar")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(sample.urgency.color.opacity(0.85))

                Text(sample.dueText)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(Colors.textSecondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: 110, alignment: .trailing)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background { WidgetTutorialHomeWidgetBackground(urgency: sample.urgency) }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct WidgetTutorialHomeWidgetBackground: View {
    let urgency: Urgency

    var body: some View {
        ZStack(alignment: .leading) {
            Color.white
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(urgency.color)
                .frame(width: 4)
                .padding(.vertical, 12)
        }
    }
}
