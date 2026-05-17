import SwiftUI

struct ChoiceCard: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CardSurface(strokeColor: isSelected ? Theme.primaryBlue : Theme.border) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFont.title(18))
                        .foregroundStyle(Theme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.caption())
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .preferredColorScheme(.light)
    }
}
