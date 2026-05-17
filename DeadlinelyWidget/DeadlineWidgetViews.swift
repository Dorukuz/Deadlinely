import SwiftUI
import WidgetKit

// MARK: - Lock Screen

struct DeadlineRectangularView: View {
    let entry: DeadlineWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .lineLimit(1)
            Text(entry.timeText)
                .font(.system(.title3, design: .rounded, weight: .heavy))
                .foregroundStyle(entry.urgency.color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            entry.urgency.color.opacity(0.12)
        }
    }
}

struct DeadlineCircularView: View {
    let entry: DeadlineWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text(entry.circularValue)
                    .font(.system(.title2, design: .rounded, weight: .heavy))
                Text(entry.circularUnit)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(entry.urgency.color)
        }
        .containerBackground(for: .widget) {
            entry.urgency.color.opacity(0.15)
        }
    }
}

struct DeadlineInlineView: View {
    let entry: DeadlineWidgetEntry

    var body: some View {
        Text(entry.inlineText)
            .font(.system(.body, design: .rounded, weight: .semibold))
    }
}

// MARK: - Home Screen

struct DeadlineHomeSmallView: View {
    let entry: DeadlineWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.isEmpty ? "Deadlinely" : entry.title)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(WidgetColors.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if !entry.isEmpty {
                    statusPill
                }
            }

            Text(entry.isEmpty ? "Add a deadline" : entry.heroText)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(entry.isEmpty ? WidgetColors.textSecondary : entry.urgency.color)
                .minimumScaleFactor(0.65)
                .lineLimit(1)

            if !entry.isEmpty {
                Text(entry.dueText)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(WidgetColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .homeWidgetBackground(urgency: entry.urgency)
    }

    private var statusPill: some View {
        Text(entry.urgency.statusLabel)
            .font(.system(size: 9, weight: .heavy, design: .rounded))
            .foregroundStyle(entry.urgency.color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(entry.urgency.color.opacity(0.15)))
    }
}

struct DeadlineHomeMediumView: View {
    let entry: DeadlineWidgetEntry

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("TIME LEFT")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(WidgetColors.textSecondary)

                Text(entry.isEmpty ? "Add one" : entry.heroText)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(entry.isEmpty ? WidgetColors.textSecondary : entry.urgency.color)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(entry.isEmpty ? "Open Deadlinely to add your first countdown" : entry.title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(WidgetColors.textPrimary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            if !entry.isEmpty {
                VStack(alignment: .trailing, spacing: 8) {
                    Text(entry.urgency.statusLabel)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(entry.urgency.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(entry.urgency.color.opacity(0.12)))

                    Image(systemName: "calendar")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(entry.urgency.color.opacity(0.85))

                    Text(entry.dueText)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(WidgetColors.textSecondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                .frame(maxWidth: 110, alignment: .trailing)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .homeWidgetBackground(urgency: entry.urgency)
    }
}

// MARK: - Home styling

private enum WidgetColors {
    static let textPrimary = Color(red: 0.12, green: 0.14, blue: 0.18)
    static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.52)
}

private extension View {
    func homeWidgetBackground(urgency: WidgetUrgency) -> some View {
        containerBackground(for: .widget) {
            ZStack(alignment: .leading) {
                Color.white
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(urgency.color)
                    .frame(width: 4)
                    .padding(.vertical, 12)
            }
        }
    }
}
