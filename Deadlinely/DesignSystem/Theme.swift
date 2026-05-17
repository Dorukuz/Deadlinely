import SwiftUI

enum Theme {
    static let background = Color.white
    static let border = Color(red: 0.90, green: 0.91, blue: 0.92)
    static let textPrimary = Color(red: 0.12, green: 0.14, blue: 0.18)
    static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.52)

    static let primaryBlue = Color(red: 0.22, green: 0.52, blue: 0.98)
    static let primaryBlueShadow = Color(red: 0.12, green: 0.38, blue: 0.82)
    static let welcomeGreen = Color(red: 0.34, green: 0.78, blue: 0.42)
    static let welcomeGreenShadow = Color(red: 0.22, green: 0.62, blue: 0.32)

    static let horizontalPadding: CGFloat = 20
    static let maxContentWidth: CGFloat = 540
    static let cardCornerRadius: CGFloat = 16
    static let strokeWidth: CGFloat = 2
}

struct ContentWidthModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: Theme.maxContentWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Theme.horizontalPadding)
    }
}

extension View {
    func contentWidth() -> some View {
        modifier(ContentWidthModifier())
    }

    /// Light surfaces with dark text; avoids system dark mode rendering white labels on white cards.
    func deadlinelyLightSurface() -> some View {
        self
            .preferredColorScheme(.light)
            .background(Theme.background)
            .tint(.duoBlue)
    }

    /// Sheets, lists, and forms; force readable labels and control tinting.
    func deadlinelyReadableContent() -> some View {
        self
            .preferredColorScheme(.light)
            .tint(.duoBlue)
    }
}
