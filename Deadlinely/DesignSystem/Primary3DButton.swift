import SwiftUI

struct Primary3DButton: View {
    let title: String
    var color: Color = Theme.primaryBlue
    var shadowColor: Color = Theme.primaryBlueShadow
    var action: () -> Void

    var body: some View {
        Button {
            Haptic.medium()
            action()
        } label: {
            TrackedButtonLabel(title: title)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color)
                        .shadow(color: shadowColor.opacity(0.45), radius: 0, x: 0, y: 4)
                )
        }
        .buttonStyle(.plain)
        .preferredColorScheme(.light)
    }
}
