import SwiftUI

struct OnboardingFinnCoach: View {
    let pose: FinnPose
    let stroke: Color
    let fill: Color
    let title: String
    let message: String
    var compact: Bool

    init(pose: FinnPose, stroke: Color, fill: Color, title: String, message: String, compact: Bool = false) {
        self.pose = pose
        self.stroke = stroke
        self.fill = fill
        self.title = title
        self.message = message
        self.compact = compact
    }

    init(mood: OnboardingFinnMood, title: String, message: String, compact: Bool = false) {
        self.pose = mood.pose
        self.stroke = mood.stroke
        self.fill = mood.fill
        self.title = title
        self.message = message
        self.compact = compact
    }

    var body: some View {
        HStack(alignment: .center, spacing: compact ? 10 : 12) {
            FinnAvatar(pose: pose, size: compact ? 56 : 92)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: compact ? 2 : 6) {
                Text(title)
                    .font(compact ? AppFont.title(16) : AppFont.title(18))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(compact ? 2 : nil)
                if !compact {
                    Text(message)
                        .font(AppFont.body(15))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(message)
                        .font(AppFont.body(13))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(compact ? 10 : 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
                    .strokeBorder(stroke, lineWidth: Theme.strokeWidth)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum OnboardingFinnMood {
    case calm
    case celebrate
    case thinking
    case caution

    var pose: FinnPose {
        switch self {
        case .calm: .wave
        case .celebrate: .celebrate
        case .thinking: .thinking
        case .caution: .sad
        }
    }

    var stroke: Color {
        switch self {
        case .calm: .duoBlue
        case .celebrate: .duoGreen
        case .thinking: .duoYellow
        case .caution: .duoRed
        }
    }

    var fill: Color {
        switch self {
        case .calm: .duoBlueSoft
        case .celebrate: .duoGreenSoft
        case .thinking: .duoYellowSoft
        case .caution: .duoRedSoft
        }
    }
}
