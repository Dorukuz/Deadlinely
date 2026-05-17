import SwiftUI

struct StickyBottomBar: View {
    let primaryTitle: String
    var primaryColor: Color = Theme.primaryBlue
    var primaryShadow: Color = Theme.primaryBlueShadow
    var secondaryTitle: String?
    var primaryDisabled: Bool = false
    var primaryID: String = AccessibilityID.onboardingContinue
    let primaryAction: () -> Void
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Primary3DButton(title: primaryTitle, color: primaryColor, shadowColor: primaryShadow) {
                primaryAction()
            }
            .disabled(primaryDisabled)
            .opacity(primaryDisabled ? 0.5 : 1)
            .accessibilityIdentifier(primaryID)

            if let secondaryTitle, let secondaryAction {
                SecondaryOutlinedButton(title: secondaryTitle, action: secondaryAction)
                    .accessibilityIdentifier(AccessibilityID.onboardingNotNow)
            }
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Theme.background
                .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
        )
    }
}
