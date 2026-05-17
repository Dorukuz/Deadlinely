import SwiftData
import SwiftUI
import UIKit

enum CountdownFocus: String, CaseIterable {
    case exams
    case projects
    case both

    var title: String {
        switch self {
        case .exams: "Exams & finals"
        case .projects: "Projects & deliverables"
        case .both: "Both, full picture"
        }
    }

    var subtitle: String {
        switch self {
        case .exams: "Midterms, finals, and test days"
        case .projects: "Capstones, launches, and due dates"
        case .both: "Everything you're counting down to"
        }
    }

    var icon: String {
        switch self {
        case .exams: "graduationcap.fill"
        case .projects: "folder.fill"
        case .both: "square.grid.2x2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .exams: .duoBlue
        case .projects: .duoPurple
        case .both: .duoBlue
        }
    }
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    let onFinished: () -> Void

    @State private var step = 0
    @State private var focus: CountdownFocus = .exams
    @State private var title1 = ""
    @State private var targetDate1 = Date().addingTimeInterval(86_400 * 14)
    @State private var title2 = ""
    @State private var targetDate2 = Date().addingTimeInterval(86_400 * 30)
    @State private var skippedSecondDeadline = false
    @State private var isKeyboardVisible = false
    @State private var notificationPromptInFlight = false
    private let totalSteps = 5

    private var previewRemaining: TimeRemaining {
        TimeRemaining(from: targetDate1)
    }

    private var previewUrgency: Urgency {
        Urgency(timeRemaining: targetDate1.timeIntervalSinceNow)
    }

    private var previewFinnMood: OnboardingFinnMood {
        switch previewUrgency {
        case .green: return .celebrate
        case .yellow: return .thinking
        case .red, .purple: return .caution
        }
    }

    private var previewCoachTitle: String {
        switch previewUrgency {
        case .green: return "Looks doable!"
        case .yellow: return "It's getting close."
        case .red: return "Soon. You've got this."
        case .purple: return "That date passed."
        }
    }

    private var usesCompactFixedLayout: Bool {
        step == 2 || step == 3 || step == 4
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if step > 0 {
                    OnboardingTopBar(progress: Double(step) / Double(totalSteps)) {
                        complete(saveData: false)
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }

                Group {
                    if usesCompactFixedLayout {
                        compactStepContent
                            .padding(.horizontal, Theme.horizontalPadding)
                            .padding(.top, 12)
                            .frame(maxWidth: Theme.maxContentWidth)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            scrollableStepContent
                                .padding(.horizontal, Theme.horizontalPadding)
                                .padding(.top, 20)
                                .padding(.bottom, 24)
                                .frame(maxWidth: Theme.maxContentWidth)
                                .frame(maxWidth: .infinity)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                }
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                stickyBottomBar
            }
        }
        .deadlinelyReadableContent()
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            isKeyboardVisible = false
        }
        .onAppear {
            #if DEBUG
            if let initialStep = ScreenshotLaunchHelper.consumeOnboardingStep() {
                step = initialStep
            }
            if let seededTitle = UserDefaults.standard.string(forKey: "screenshot_onboardingTitle1") {
                title1 = seededTitle
            }
            #endif
        }
        #if DEBUG
        .screenshotSignalsReady(
            forModes: "onboarding-welcome", "onboarding-deadline",
            minSettle: 0.9,
            afterFinnExtra: 1.6,
            maxFinnWait: 8
        )
        #endif
    }

    // MARK: - Step 0 Welcome

    private var welcomeStep: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 8)
            FinnAvatar(pose: .wave, size: 190)
            VStack(spacing: 12) {
                Text("See what's left before go-time.")
                    .font(AppFont.headline(30))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Add your deadlines once. Glance at days and hours on your Lock Screen.")
                    .font(AppFont.body(17))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            HStack(spacing: 16) {
                welcomeBadge(icon: "calendar.badge.clock", tint: .duoBlue, label: "Exams")
                welcomeBadge(icon: "folder.fill", tint: .duoPurple, label: "Projects")
                welcomeBadge(icon: "lock.square", tint: .duoYellow, label: "Widget")
            }
            .padding(.top, 4)
            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity)
    }

    private func welcomeBadge(icon: String, tint: Color, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(tint.opacity(0.15))
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(tint)
            }
            .frame(width: 60, height: 60)
            Text(label.uppercased())
                .font(AppFont.caption())
                .tracking(1.0)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: - Step 1 Focus

    private var focusStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            OnboardingFinnCoach(
                mood: .calm,
                title: "First, what are you tracking?",
                message: "Pick the vibe. You can count down to anything later."
            )

            VStack(spacing: 12) {
                ForEach(CountdownFocus.allCases, id: \.self) { option in
                    DuoChoiceCard(isSelected: focus == option, tint: option.tint) {
                        focus = option
                    } content: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(option.tint.opacity(0.15))
                                Image(systemName: option.icon)
                                    .font(.system(size: 22, weight: .heavy))
                                    .foregroundStyle(option.tint)
                            }
                            .frame(width: 48, height: 48)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.title)
                                    .font(AppFont.title(17))
                                    .foregroundStyle(Theme.textPrimary)
                                Text(option.subtitle)
                                    .font(AppFont.body(14))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var scrollableStepContent: some View {
        switch step {
        case 0: welcomeStep
        case 1: focusStep
        default: notificationsStep
        }
    }

    @ViewBuilder
    private var compactStepContent: some View {
        switch step {
        case 2: firstDeadlineStep
        case 3: secondDeadlineStep
        case 4: previewStep
        default: EmptyView()
        }
    }

    // MARK: - Step 2 First deadline

    private var firstDeadlineStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            OnboardingFinnCoach(
                mood: .calm,
                title: "Your next go-time",
                message: "Name it and pick a date.",
                compact: true
            )

            fieldLabel("DEADLINE NAME", tint: .duoBlue)
            DeadlineTextField(placeholder: placeholderForFocus, text: $title1)

            fieldLabel("DUE DATE", tint: .duoBlue)
            OnboardingDateField(date: $targetDate1, tint: .duoBlue)

            OnboardingCompactPreview(
                value: previewRemaining.compactDaysHours,
                subtitle: title1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? "Your countdown" : title1,
                tint: previewUrgency.color
            )

            Spacer(minLength: 0)
        }
    }

    private var placeholderForFocus: String {
        switch focus {
        case .exams: "e.g. Organic Chemistry final"
        case .projects: "e.g. Capstone presentation"
        case .both: "e.g. Midterm week"
        }
    }

    // MARK: - Step 3 Second deadline

    private var secondDeadlineStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            OnboardingFinnCoach(
                mood: .thinking,
                title: "Another deadline?",
                message: "Optional. Or tap Not now below.",
                compact: true
            )

            fieldLabel("SECOND DEADLINE", tint: .duoPurple)
            DeadlineTextField(placeholder: "e.g. Portfolio submission", text: $title2)

            fieldLabel("DUE DATE", tint: .duoPurple)
            OnboardingDateField(date: $targetDate2, tint: .duoPurple)

            OnboardingCompactPreview(
                value: validSecondTitle ? "2 deadlines" : "1 deadline",
                subtitle: "ready to track",
                tint: .duoPurple
            )

            Spacer(minLength: 0)
        }
    }

    private var validSecondTitle: Bool {
        !title2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Step 4 Preview / aha

    private var previewStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            OnboardingFinnCoach(
                pose: previewFinnMood.pose,
                stroke: previewFinnMood.stroke,
                fill: previewFinnMood.fill,
                title: previewCoachTitle,
                message: "Here's your live countdown on home and Lock Screen.",
                compact: true
            )

            OnboardingPreviewHeroCard(
                title: title1,
                targetDate: targetDate1
            )

            Spacer(minLength: 0)
        }
    }

    // MARK: - Step 5 Notifications

    private var notificationsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            OnboardingFinnCoach(
                mood: .calm,
                title: "Want a gentle heads-up?",
                message: "Optional reminders before go-time. Turn them off anytime."
            )
            benefitRow(icon: "bell.badge.fill", tint: .duoBlue, title: "Friendly nudges", subtitle: "A day before and the morning of")
            benefitRow(icon: "hand.raised.fill", tint: .duoPurple, title: "You're in control", subtitle: "Allow now or skip. No pressure.")
            benefitRow(icon: "moon.stars.fill", tint: .duoYellow, title: "Calm tempo", subtitle: "Finn keeps it shame-free")
        }
    }

    private func benefitRow(icon: String, tint: Color, title: String, subtitle: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.15))
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(tint)
            }
            .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.title(17))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(AppFont.body(14))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .duoCard(stroke: tint.opacity(0.35))
    }

    private func fieldLabel(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(AppFont.caption())
            .tracking(1.2)
            .foregroundStyle(tint)
    }

    // MARK: - Bottom bar

    private var stickyBottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(Theme.border)
            HStack(spacing: 12) {
                if step > 0 {
                    Button {
                        Haptic.soft()
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { step -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(width: 56, height: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Theme.border, lineWidth: Theme.strokeWidth)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")
                }

                bottomPrimarySection
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(Theme.background)
        }
    }

    @ViewBuilder
    private var bottomPrimarySection: some View {
        if step == 3 {
            VStack(spacing: 8) {
                primaryCTAButton
                Button(action: skipSecondAndAdvance) {
                    Text("Not now")
                        .foregroundStyle(Color.duoPurple)
                }
                .buttonStyle(DuoSecondaryButtonStyle(tint: .duoPurple, height: 44))
                .accessibilityIdentifier(AccessibilityID.onboardingNotNow)
            }
            .frame(maxWidth: .infinity)
        } else if step == totalSteps {
            VStack(spacing: 8) {
                Button { requestNotificationsThenFinish() } label: {
                    if notificationPromptInFlight {
                        ProgressView().tint(.white)
                    } else {
                        Text("Allow notifications")
                            .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(DuoButtonStyle(tint: .duoBlue, shadowTint: .duoBlueShadow))
                .disabled(notificationPromptInFlight)
                .accessibilityIdentifier(AccessibilityID.onboardingAllowNotifications)

                Button { declineNotificationsAndFinish() } label: {
                    Text("Not now")
                        .foregroundStyle(Color.duoBlue)
                }
                .buttonStyle(DuoSecondaryButtonStyle(tint: .duoBlue, height: 44))
                .disabled(notificationPromptInFlight)
                .accessibilityIdentifier(AccessibilityID.onboardingNotNow)
            }
            .frame(maxWidth: .infinity)
        } else {
            primaryCTAButton
        }
    }

    private var primaryCTAButton: some View {
        Button(action: handlePrimaryCTA) {
            Text(primaryTitle)
                .foregroundStyle(canAdvance ? Color.white : Theme.textSecondary)
        }
        .buttonStyle(DuoButtonStyle(tint: ctaTint, shadowTint: ctaShadow, disabled: !canAdvance))
        .disabled(!canAdvance)
        .accessibilityIdentifier(AccessibilityID.onboardingContinue)
        .frame(maxWidth: .infinity)
    }

    private var primaryTitle: String {
        switch step {
        case 0: return "Get Started"
        case 4: return "Start Countdown"
        default: return "Continue"
        }
    }

    private var ctaTint: Color {
        switch step {
        case 0, 4: return .duoGreen
        default: return .duoBlue
        }
    }

    private var ctaShadow: Color {
        switch step {
        case 0, 4: return .duoGreenShadow
        default: return .duoBlueShadow
        }
    }

    private var canAdvance: Bool {
        switch step {
        case 2:
            return !title1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 3:
            return validSecondTitle
        default:
            return true
        }
    }

    private var primaryCTAUsesKeyboardDismissFirst: Bool {
        step == 2 || step == 3
    }

    private func handlePrimaryCTA() {
        if primaryCTAUsesKeyboardDismissFirst, isKeyboardVisible {
            Haptic.soft()
            dismissKeyboard()
            return
        }
        advance()
    }

    private func skipSecondAndAdvance() {
        dismissKeyboard()
        skippedSecondDeadline = true
        Haptic.medium()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { step += 1 }
    }

    private func advance() {
        Haptic.medium()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            step += 1
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Finish

    private func requestNotificationsThenFinish() {
        guard !notificationPromptInFlight else { return }
        Haptic.medium()
        notificationPromptInFlight = true
        Task {
            _ = await NotificationService.shared.requestAuthorization()
            await MainActor.run {
                notificationPromptInFlight = false
                Haptic.success()
                complete(saveData: true)
            }
        }
    }

    private func declineNotificationsAndFinish() {
        Haptic.soft()
        complete(saveData: true)
    }

    private func complete(saveData: Bool) {
        if saveData {
            saveDeadlines()
        }
        onFinished()
    }

    private func saveDeadlines() {
        let trimmed1 = title1.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed1.isEmpty else { return }

        let first = DeadlineItem(title: trimmed1, targetDate: targetDate1)
        modelContext.insert(first)
        Task { await NotificationService.shared.scheduleReminders(for: first) }

        if !skippedSecondDeadline {
            let trimmed2 = title2.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed2.isEmpty {
                let second = DeadlineItem(title: trimmed2, targetDate: targetDate2)
                modelContext.insert(second)
                Task { await NotificationService.shared.scheduleReminders(for: second) }
            }
        }
        try? modelContext.save()
        WidgetRefresh.reloadCountdowns()
    }

}
