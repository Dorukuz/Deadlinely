import SwiftUI

struct ProWelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            ProWelcomeStyle.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                VStack(spacing: 20) {
                    proBadge

                    FinnAvatar(pose: .thumbsUp, size: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.duoGreen.opacity(0.25), radius: 20, y: 10)

                    VStack(spacing: 10) {
                        Text("Welcome to Pro!")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(ProWelcomeStyle.navy)
                            .multilineTextAlignment(.center)

                        Text("You're all set. Finn's got your back from here.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(ProWelcomeStyle.grey)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 8)
                }

                VStack(spacing: 12) {
                    ProWelcomeBenefitRow(
                        icon: "infinity",
                        tint: .duoBlue,
                        title: "Unlimited deadlines",
                        subtitle: "Track every exam and deliverable."
                    )
                    ProWelcomeBenefitRow(
                        icon: "bell.badge.fill",
                        tint: .duoPurple,
                        title: "Smart reminders",
                        subtitle: "Day-before and morning-of nudges."
                    )
                    ProWelcomeBenefitRow(
                        icon: "rectangle.on.rectangle.angled",
                        tint: .duoGreen,
                        title: "Home & Lock Screen widgets",
                        subtitle: "Your countdown, always visible."
                    )
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 16, y: 6)
                )
                .padding(.top, 28)

                Spacer(minLength: 20)

                Button {
                    Haptic.success()
                    onContinue()
                } label: {
                    Text("LET'S GO")
                }
                .buttonStyle(DuoButtonStyle(tint: .duoGreen, shadowTint: .duoGreenShadow, height: 56))
                .padding(.bottom, 12)
            }
            .contentWidth()
            .padding(.horizontal, Theme.horizontalPadding)
        }
        .preferredColorScheme(.light)
        .interactiveDismissDisabled(true)
        #if DEBUG
        .screenshotSignalsReady(
            forModes: "pro-welcome",
            minSettle: 0.7,
            afterFinnExtra: 1.6,
            maxFinnWait: 8
        )
        #endif
    }

    private var proBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 14, weight: .bold))
            Text("DEADLINELY PRO")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .tracking(0.8)
        }
        .foregroundStyle(Color.duoGreen)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.duoGreenSoft)
                .overlay(Capsule().stroke(Color.duoGreen.opacity(0.35), lineWidth: 1.5))
        )
    }
}

private struct ProWelcomeBenefitRow: View {
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(ProWelcomeStyle.navy)
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(ProWelcomeStyle.grey)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

private enum ProWelcomeStyle {
    static let navy = Color(red: 0.10, green: 0.11, blue: 0.18)
    static let grey = Color(red: 0.45, green: 0.48, blue: 0.52)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 0.99, blue: 0.95),
                Color(red: 0.97, green: 0.95, blue: 1.0),
                Color(red: 0.94, green: 0.96, blue: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
