import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable private var revenueCat = RevenueCatService.shared
    @State private var showPaywall = false
    @State private var showDeleteDataConfirm = false
    @State private var isDeletingLocalData = false
    @State private var deleteDataError: String?

    var body: some View {
        SheetChrome(title: "Settings", onDismiss: { dismiss() }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    proHeroCard

                    settingsGroup(title: "SUBSCRIPTION") {
                        settingsActionRow(
                            icon: "arrow.clockwise",
                            tint: .duoBlue,
                            title: "Restore purchases",
                            subtitle: "Use your existing App Store subscription"
                        ) {
                            Task { await revenueCat.restore() }
                        }
                        .disabled(revenueCat.isLoading)
                        .opacity(revenueCat.isLoading ? 0.6 : 1)
                    }

                    if let error = revenueCat.lastError {
                        Text(error)
                            .font(AppFont.caption())
                            .foregroundStyle(Color.duoRed)
                            .padding(.horizontal, 4)
                    }

                    settingsGroup(title: "DATA") {
                        settingsDestructiveRow(
                            icon: "trash.fill",
                            title: "Delete local data",
                            subtitle: "Remove all deadlines on this device"
                        ) {
                            showDeleteDataConfirm = true
                        }
                        .disabled(isDeletingLocalData)
                        .opacity(isDeletingLocalData ? 0.6 : 1)
                    }

                    if let deleteDataError {
                        Text(deleteDataError)
                            .font(AppFont.caption())
                            .foregroundStyle(Color.duoRed)
                            .padding(.horizontal, 4)
                    }
                }
                .contentWidth()
                .padding(.vertical, 20)
            }
            .background(Theme.background)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
        }
        .confirmationDialog(
            "Delete all local data?",
            isPresented: $showDeleteDataConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete local data", role: .destructive) {
                Task { await deleteLocalData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes every deadline, cancels their reminders, and returns you to the welcome flow. Your subscription is not affected.")
        }
        #if DEBUG
        .screenshotSignalsReady(
            forModes: "settings",
            minSettle: 0.9,
            afterFinnExtra: 0.5,
            maxFinnWait: 4
        )
        #endif
    }

    private func deleteLocalData() async {
        isDeletingLocalData = true
        deleteDataError = nil
        defer { isDeletingLocalData = false }
        do {
            try await LocalDataDeletionService.deleteAll(modelContext: modelContext)
            Haptic.success()
            dismiss()
        } catch {
            deleteDataError = error.localizedDescription
            Haptic.medium()
        }
    }

    // MARK: - Pro hero

    @ViewBuilder
    private var proHeroCard: some View {
        if revenueCat.isPro {
            proActiveCard
        } else {
            proUpgradeCard
        }
    }

    private var proActiveCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.duoGreenSoft)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color.duoGreen)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Deadlinely Pro")
                        .font(AppFont.title(20))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Unlimited deadlines, widget, and reminders.")
                        .font(AppFont.body(14))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 8) {
                proBadge("Unlimited")
                proBadge("Lock Screen")
                proBadge("Active")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.duoGreenSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.duoGreen.opacity(0.35), lineWidth: Theme.strokeWidth)
        )
    }

    private var proUpgradeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.duoBlueSoft)
                    Image(systemName: "star.fill")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.duoBlue)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Go Pro")
                        .font(AppFont.title(20))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Track every exam and project without limits.")
                        .font(AppFont.body(14))
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                proBenefitRow("infinity", "Unlimited countdowns")
                proBenefitRow("lock.square", "Lock Screen widget")
                proBenefitRow("bell.fill", "Reminders included")
            }

            Button {
                showPaywall = true
            } label: {
                Text("Upgrade to Pro")
            }
            .buttonStyle(DuoButtonStyle(tint: .duoBlue, shadowTint: .duoBlueShadow, height: 50))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.duoBlue.opacity(0.3), lineWidth: Theme.strokeWidth)
        )
        .shadow(color: Color.duoBlue.opacity(0.08), radius: 12, y: 4)
    }

    private func proBenefitRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.duoBlue)
                .frame(width: 22)
            Text(text)
                .font(AppFont.body(14))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private func proBadge(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AppFont.caption())
            .tracking(0.5)
            .foregroundStyle(Color.duoGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.85)))
    }

    // MARK: - Groups & rows

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.caption())
                .tracking(1.0)
                .foregroundStyle(Theme.textSecondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.border, lineWidth: Theme.strokeWidth)
            )
        }
    }

    private func settingsActionRow(
        icon: String,
        tint: Color,
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.12))
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(tint)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.body(16))
                        .foregroundStyle(Theme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.caption())
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer(minLength: 8)

                if revenueCat.isLoading {
                    ProgressView()
                        .tint(tint)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.textSecondary.opacity(0.5))
                }
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func settingsDestructiveRow(
        icon: String,
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.duoRedSoft)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.duoRed)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.body(16))
                        .foregroundStyle(Color.duoRed)
                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.caption())
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer(minLength: 8)

                if isDeletingLocalData {
                    ProgressView()
                        .tint(Color.duoRed)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
