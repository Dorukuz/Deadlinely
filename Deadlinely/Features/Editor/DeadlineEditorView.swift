import SwiftData
import SwiftUI

struct DeadlineEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let item: DeadlineItem?
    var onSave: (DeadlineItem?) -> Void

    @Bindable private var revenueCat = RevenueCatService.shared
    @Query(filter: #Predicate<DeadlineItem> { !$0.isDone })
    private var activeDeadlines: [DeadlineItem]

    @State private var title = ""
    @State private var targetDate = Date().addingTimeInterval(86_400 * 7)
    @State private var reminderDayBefore = true
    @State private var reminderMorningOf = true
    @State private var showPaywall = false

    var body: some View {
        SheetChrome(title: item == nil ? "New deadline" : "Edit deadline", onDismiss: { dismiss() }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("Title")
                        DeadlineTextField(placeholder: "Final exam, capstone…", text: $title)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("Due date")
                        EditorDatePickerCard(date: $targetDate)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("Reminders")
                        EditorRemindersCard(
                            reminderDayBefore: $reminderDayBefore,
                            reminderMorningOf: $reminderMorningOf
                        )
                    }

                    if let item {
                        if item.isDone {
                            Button("Mark as active again") {
                                markActive(item)
                            }
                            .buttonStyle(DuoSecondaryButtonStyle(tint: .duoBlue, height: 44))
                        } else {
                            Button("Mark as done") {
                                markDone(item)
                            }
                            .buttonStyle(DuoSecondaryButtonStyle(tint: .duoGreen, height: 44))
                        }
                    }

                    Primary3DButton(title: "Save") {
                        save()
                    }
                    .accessibilityIdentifier(AccessibilityID.editorSave)
                    .padding(.top, 8)
                }
                .contentWidth()
                .padding(.vertical, 20)
                .deadlinelyReadableContent()
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
        }
        .onAppear { loadFromItem() }
        .onChange(of: item?.id) { _, _ in loadFromItem() }
        #if DEBUG
        .screenshotSignalsReady(
            forModes: "editor",
            minSettle: 0.8,
            afterFinnExtra: 0.6,
            maxFinnWait: 4
        )
        #endif
    }

    private func loadFromItem() {
        guard let item else {
            title = ""
            targetDate = Date().addingTimeInterval(86_400 * 7)
            reminderDayBefore = true
            reminderMorningOf = true
            return
        }
        title = item.title
        targetDate = item.targetDate
        reminderDayBefore = item.reminderDayBefore
        reminderMorningOf = item.reminderMorningOf
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if item == nil,
           !DeadlineLimitService.canAddDeadline(count: activeDeadlines.count, isPro: revenueCat.isPro) {
            showPaywall = true
            return
        }

        Haptic.success()
        let saved: DeadlineItem
        if let item {
            item.title = trimmed
            item.targetDate = targetDate
            item.reminderDayBefore = reminderDayBefore
            item.reminderMorningOf = reminderMorningOf
            saved = item
        } else {
            let newItem = DeadlineItem(
                title: trimmed,
                targetDate: targetDate,
                reminderDayBefore: reminderDayBefore,
                reminderMorningOf: reminderMorningOf
            )
            modelContext.insert(newItem)
            saved = newItem
        }
        try? modelContext.save()
        WidgetRefresh.reloadCountdowns()
        onSave(saved)
        dismiss()
    }

    private func markDone(_ item: DeadlineItem) {
        item.isDone = true
        item.completedAt = .now
        try? modelContext.save()
        Haptic.success()
        AppReviewService.considerPromptAfterDeadlineCompleted(modelContext: modelContext)
        WidgetRefresh.reloadCountdowns()
        Task { await NotificationService.shared.removeReminders(for: item.id) }
        onSave(nil)
        dismiss()
    }

    private func markActive(_ item: DeadlineItem) {
        item.isDone = false
        item.completedAt = nil
        try? modelContext.save()
        Haptic.light()
        WidgetRefresh.reloadCountdowns()
        Task { await NotificationService.shared.scheduleReminders(for: item) }
        onSave(item)
        dismiss()
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(AppFont.caption())
            .foregroundStyle(Theme.textSecondary)
    }
}
