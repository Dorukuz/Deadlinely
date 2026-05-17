import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppFont.title(20))
            .foregroundStyle(Theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
