import SwiftUI

struct SheetChrome<Content: View>: View {
    let title: String
    var onDismiss: (() -> Void)?
    var dismissAccessibilityID: String?
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .background(Theme.background)
                .deadlinelyReadableContent()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.light, for: .navigationBar)
                .toolbarBackground(Theme.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    if let onDismiss {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                onDismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .modifier(OptionalAccessibilityIdentifier(identifier: dismissAccessibilityID))
                        }
                    }
                }
        }
        .presentationBackground(Theme.background)
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.light)
    }
}
