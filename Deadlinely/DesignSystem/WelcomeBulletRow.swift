import SwiftUI

struct WelcomeBulletRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.primaryBlue)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.primaryBlue.opacity(0.12)))
            Text(text)
                .font(AppFont.body())
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}
