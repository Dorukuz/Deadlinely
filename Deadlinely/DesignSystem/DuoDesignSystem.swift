import SwiftUI

// MARK: - Duo palette (onboarding + app accents)

extension Color {
    static let duoBlue = Theme.primaryBlue
    static let duoBlueShadow = Theme.primaryBlueShadow
    static let duoBlueSoft = Color(red: 0.88, green: 0.94, blue: 1.0)

    static let duoGreen = Theme.welcomeGreen
    static let duoGreenShadow = Theme.welcomeGreenShadow
    static let duoGreenSoft = Color(red: 0.91, green: 0.97, blue: 0.84)

    static let duoYellow = Color(red: 1.0, green: 0.78, blue: 0.0)
    static let duoYellowShadow = Color(red: 0.82, green: 0.62, blue: 0.0)
    static let duoYellowSoft = Color(red: 1.0, green: 0.96, blue: 0.78)

    static let duoRed = Color(red: 1.0, green: 0.32, blue: 0.32)
    static let duoRedShadow = Color(red: 0.78, green: 0.18, blue: 0.18)
    static let duoRedSoft = Color(red: 1.0, green: 0.89, blue: 0.89)

    static let duoPurple = Color(red: 0.58, green: 0.42, blue: 0.92)
    static let duoPurpleShadow = Color(red: 0.42, green: 0.28, blue: 0.72)
    static let duoPurpleSoft = Color(red: 0.96, green: 0.91, blue: 1.0)
}

extension View {
    func duoCard(cornerRadius: CGFloat = 18, stroke: Color = Theme.border, fill: Color = .white) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(fill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(stroke, lineWidth: Theme.strokeWidth)
        )
    }
}

// MARK: - 3D buttons

struct DuoButtonStyle: ButtonStyle {
    var tint: Color = .duoBlue
    var shadowTint: Color = .duoBlueShadow
    var disabled: Bool = false
    var height: CGFloat = 54

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && !disabled
        let face = disabled ? Theme.border : tint
        let base = disabled ? Theme.border : shadowTint

        return ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(base)
                .frame(height: height)
                .offset(y: 4)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(face)
                .frame(height: height)
                .overlay {
                    configuration.label
                        .font(AppFont.button())
                        .textCase(.uppercase)
                        .tracking(1.0)
                        .foregroundStyle(disabled ? Theme.textSecondary : Color.white)
                        .frame(height: height)
                }
                .offset(y: pressed ? 4 : 0)
        }
        .frame(height: height + 4)
        .animation(.spring(response: 0.18, dampingFraction: 0.7), value: pressed)
        .preferredColorScheme(.light)
    }
}

struct DuoSecondaryButtonStyle: ButtonStyle {
    var tint: Color = Theme.textPrimary
    var height: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.border)
                .frame(height: height)
                .offset(y: 4)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Theme.border, lineWidth: Theme.strokeWidth)
                )
                .frame(height: height)
                .overlay {
                    configuration.label
                        .font(AppFont.button())
                        .textCase(.uppercase)
                        .tracking(1.0)
                        .foregroundStyle(tint)
                        .frame(height: height)
                }
                .offset(y: pressed ? 4 : 0)
        }
        .frame(height: height + 4)
        .preferredColorScheme(.light)
    }
}

// MARK: - Choice card

struct DuoChoiceCard<Content: View>: View {
    var isSelected: Bool
    var tint: Color = .duoBlue
    var action: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.45) : Theme.border)
                    .offset(y: 4)
                content()
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(isSelected ? tint.opacity(0.08) : .white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(isSelected ? tint : Theme.border, lineWidth: Theme.strokeWidth)
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22, dampingFraction: 0.75), value: isSelected)
    }
}

// MARK: - Progress

struct DuoProgressBar: View {
    var progress: Double
    var tint: Color = .duoGreen

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.border)
                Capsule()
                    .fill(tint)
                    .frame(width: max(16, geo.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: 16)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: progress)
    }
}

struct OnboardingTopBar: View {
    var progress: Double
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.onboardingClose)

            DuoProgressBar(progress: progress, tint: .duoGreen)
        }
    }
}

// MARK: - Preview card

struct OnboardingPreviewCard: View {
    let eyebrow: String
    let value: String
    let trailing: String
    let tint: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow.uppercased())
                    .font(AppFont.caption())
                    .tracking(1.2)
                    .foregroundStyle(Theme.textSecondary)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(value)
                        .font(AppFont.title(22))
                        .foregroundStyle(Theme.textPrimary)
                    Text(trailing)
                        .font(AppFont.body(15))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer()
            ZStack {
                Circle().fill(tint.opacity(0.15))
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(tint)
            }
            .frame(width: 42, height: 42)
        }
        .padding(16)
        .duoCard(stroke: tint.opacity(0.4))
    }
}
