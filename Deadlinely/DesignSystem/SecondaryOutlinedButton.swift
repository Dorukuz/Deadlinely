import SwiftUI

struct SecondaryOutlinedButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            TrackedButtonLabel(title: title)
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.border, lineWidth: Theme.strokeWidth)
                )
        }
        .buttonStyle(.plain)
        .preferredColorScheme(.light)
    }
}
