import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<DeadlineItem> { !$0.isDone }, sort: \DeadlineItem.targetDate)
    private var activeDeadlines: [DeadlineItem]
    @Query(filter: #Predicate<DeadlineItem> { $0.isDone }, sort: \DeadlineItem.completedAt, order: .reverse)
    private var completedDeadlines: [DeadlineItem]

    @Bindable private var revenueCat = RevenueCatService.shared

    @State private var editorSheet: DeadlineEditorSheet?
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var measuredContentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0

    private var hasAnyDeadlines: Bool {
        !activeDeadlines.isEmpty || !completedDeadlines.isEmpty
    }

    private var scrollingNeeded: Bool {
        guard viewportHeight > 0, measuredContentHeight > 0 else { return false }
        return measuredContentHeight > viewportHeight + 8
    }

    var body: some View {
        NavigationStack {
            List {
                homeListContent
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollDisabled(!scrollingNeeded)
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: HomeViewportHeightKey.self,
                        value: geometry.size.height
                    )
                }
            }
            .overlay(alignment: .top) {
                homeContentMeasureStack
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
                    .background {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: HomeContentHeightKey.self,
                                value: geometry.size.height
                            )
                        }
                    }
            }
            .onPreferenceChange(HomeViewportHeightKey.self) { viewportHeight = $0 }
            .onPreferenceChange(HomeContentHeightKey.self) { measuredContentHeight = $0 }
            .background(Theme.background)
            .contentWidth()
            .padding(.vertical, 8)
            .navigationTitle("Deadlinely")
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        openAddFlow()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.duoGreen)
                                    .shadow(color: Color.duoGreenShadow.opacity(0.4), radius: 0, y: 3)
                            )
                    }
                    .accessibilityIdentifier(AccessibilityID.homeAddDeadline)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .overlay(Circle().stroke(Theme.border, lineWidth: Theme.strokeWidth))
                            )
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(item: $editorSheet) { presentation in
                DeadlineEditorView(item: presentation.item) { saved in
                    if let saved {
                        Task { await NotificationService.shared.scheduleReminders(for: saved) }
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .deadlinelyReadableContent()
        .task(id: activeDeadlines.map(\.id)) {
            #if DEBUG
            await applyScreenshotPresentationIfNeeded()
            #endif
        }
        .onChange(of: activeDeadlines.count) { _, _ in
            #if DEBUG
            presentScreenshotEditorIfNeeded()
            #endif
        }
        #if DEBUG
        .screenshotSignalsReady(
            forModes: "home-active", "home-completed", "home-empty",
            minSettle: 0.45,
            afterFinnExtra: 1.1,
            maxFinnWait: 6
        )
        #endif
    }

    #if DEBUG
    private func applyScreenshotPresentationIfNeeded() async {
        guard ScreenshotLaunchHelper.activeMode != nil else { return }

        if UserDefaults.standard.bool(forKey: ScreenshotLaunchHelper.forceEditorKey) {
            try? await Task.sleep(for: .seconds(1.2))
            openScreenshotEditorIfPossible()
            return
        }

        if UserDefaults.standard.bool(forKey: "screenshot_forceSettings") {
            try? await Task.sleep(for: .seconds(1.2))
            showSettings = true
        }
    }

    private func presentScreenshotEditorIfNeeded() {
        guard UserDefaults.standard.bool(forKey: ScreenshotLaunchHelper.forceEditorKey) else { return }
        openScreenshotEditorIfPossible()
    }

    private func openScreenshotEditorIfPossible() {
        guard let idString = UserDefaults.standard.string(forKey: "screenshot_editorDeadlineID"),
              let id = UUID(uuidString: idString),
              let item = activeDeadlines.first(where: { $0.id == id }) ?? activeDeadlines.first
        else { return }
        editorSheet = .edit(item)
    }
    #endif

    @ViewBuilder
    private var homeListContent: some View {
        if !hasAnyDeadlines {
            emptyState
                .deadlineListRow()
        } else {
            Section {
                homeFinnCoach
                    .deadlineListRow(verticalPadding: 8)
            }

            if !activeDeadlines.isEmpty {
                Section {
                    ForEach(Array(activeDeadlines.enumerated()), id: \.element.id) { index, item in
                        deadlineRow(item, isNextUp: index == 0, isCompleted: false)
                    }
                } header: {
                    homeListHeader
                        .textCase(nil)
                }
            }

            if !completedDeadlines.isEmpty {
                Section {
                    ForEach(completedDeadlines) { item in
                        deadlineRow(item, isNextUp: false, isCompleted: true)
                    }
                } header: {
                    completedSectionHeader
                        .textCase(nil)
                }
            }
        }
    }

    private var homeContentMeasureStack: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !hasAnyDeadlines {
                emptyState
            } else {
                homeFinnCoach

                if !activeDeadlines.isEmpty {
                    homeListHeader
                    ForEach(Array(activeDeadlines.enumerated()), id: \.element.id) { index, item in
                        DeadlineCardView(item: item, isNextUp: index == 0)
                            .padding(.vertical, 6)
                    }
                }

                if !completedDeadlines.isEmpty {
                    completedSectionHeader
                    ForEach(completedDeadlines) { item in
                        DeadlineCardView(item: item, isNextUp: false)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var homeFinnCoach: some View {
        OnboardingFinnCoach(
            mood: homeFinnMood,
            title: homeFinnTitle,
            message: homeFinnMessage,
            compact: true
        )
        .accessibilityIdentifier(AccessibilityID.homeFinnCoach)
    }

    private var homeFinnMood: OnboardingFinnMood {
        guard let next = activeDeadlines.first else { return .celebrate }
        switch next.urgency {
        case .green: return .calm
        case .yellow: return .thinking
        case .red, .purple: return .caution
        }
    }

    private var homeFinnTitle: String {
        guard let next = activeDeadlines.first else {
            return "You're all caught up!"
        }
        switch next.urgency {
        case .green: return "You're on track"
        case .yellow: return "Getting close"
        case .red: return "Crunch time"
        case .purple: return "Past due — still doable"
        }
    }

    private var homeFinnMessage: String {
        guard let next = activeDeadlines.first else {
            return "Completed deadlines are below. Add another anytime."
        }
        return "Next up: \(next.title)"
    }

    private var homeListHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(activeCountTitle)
                .font(AppFont.headline(26))
                .foregroundStyle(Theme.textPrimary)
            Text("Tap to edit · swipe for Done")
                .font(AppFont.body(14))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.bottom, 4)
    }

    private var completedSectionHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Completed")
                .font(AppFont.title(18))
                .foregroundStyle(Theme.textPrimary)
            Text("Swipe to bring a deadline back")
                .font(AppFont.body(13))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.top, activeDeadlines.isEmpty ? 0 : 8)
    }

    private var activeCountTitle: String {
        switch activeDeadlines.count {
        case 1: return "1 active deadline"
        default: return "\(activeDeadlines.count) active deadlines"
        }
    }

    private func deadlineRow(_ item: DeadlineItem, isNextUp: Bool, isCompleted: Bool) -> some View {
        DeadlineCardView(item: item, isNextUp: isNextUp && !isCompleted)
            .contentShape(Rectangle())
            .onTapGesture {
                editorSheet = .edit(item)
            }
            .deadlineListRow(verticalPadding: 6)
            .swipeActions(edge: .trailing, allowsFullSwipe: !isCompleted) {
                if !isCompleted {
                    Button {
                        markDone(item)
                    } label: {
                        Label("Done", systemImage: "checkmark.circle.fill")
                    }
                    .tint(.duoGreen)
                }
            }
            .swipeActions(edge: .leading) {
                if isCompleted {
                    Button {
                        markActive(item)
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .tint(.duoBlue)
                }
            }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            FinnAvatar(pose: .sad, size: 180)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Text("No deadlines yet")
                .font(AppFont.headline(24))
                .foregroundStyle(Theme.textPrimary)
            Text("Add your first exam or deliverable to start the countdown.")
                .font(AppFont.body())
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Primary3DButton(title: "Add deadline") {
                openAddFlow()
            }
            .accessibilityIdentifier(AccessibilityID.homeAddDeadline)
        }
        .padding(.top, 40)
    }

    private func markDone(_ item: DeadlineItem) {
        item.isDone = true
        item.completedAt = .now
        try? modelContext.save()
        Haptic.success()
        AppReviewService.considerPromptAfterDeadlineCompleted(modelContext: modelContext)
        Task {
            await NotificationService.shared.removeReminders(for: item.id)
            WidgetRefresh.reloadCountdowns()
        }
    }

    private func markActive(_ item: DeadlineItem) {
        item.isDone = false
        item.completedAt = nil
        try? modelContext.save()
        Haptic.light()
        Task {
            await NotificationService.shared.scheduleReminders(for: item)
            WidgetRefresh.reloadCountdowns()
        }
    }

    private func openAddFlow() {
        if DeadlineLimitService.canAddDeadline(count: activeDeadlines.count, isPro: revenueCat.isPro) {
            editorSheet = .new
        } else {
            showPaywall = true
        }
    }
}

private struct DeadlineEditorSheet: Identifiable {
    let id: UUID
    let item: DeadlineItem?

    static var new: DeadlineEditorSheet {
        DeadlineEditorSheet(id: UUID(), item: nil)
    }

    static func edit(_ item: DeadlineItem) -> DeadlineEditorSheet {
        DeadlineEditorSheet(id: item.id, item: item)
    }
}

private extension View {
    func deadlineListRow(verticalPadding: CGFloat = 0) -> some View {
        listRowInsets(
            EdgeInsets(
                top: verticalPadding,
                leading: 0,
                bottom: verticalPadding,
                trailing: 0
            )
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

private struct HomeContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct HomeViewportHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
