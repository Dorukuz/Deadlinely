import SwiftUI

struct CardSurface<Content: View>: View {
    var strokeColor: Color = Theme.border
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                            .stroke(strokeColor, lineWidth: Theme.strokeWidth)
                    )
            )
    }
}
