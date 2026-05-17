import SwiftUI

struct WidgetTutorialView: View {
    @Binding var isPresented: Bool
    @State private var page = 0

    private let pages = WidgetTutorialPage.all

    var body: some View {
        NavigationStack {
            ZStack {
                WidgetTutorialStyle.backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    TabView(selection: $page) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, tutorialPage in
                            WidgetTutorialPageView(page: tutorialPage)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .background(Color.clear)

                    pageIndicator
                        .padding(.top, 8)

                    bottomBar
                        .padding(.horizontal, Theme.horizontalPadding)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") {
                        finish()
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .preferredColorScheme(.light)
        .interactiveDismissDisabled(true)
        #if DEBUG
        .screenshotSignalsReady(
            forModes: "widget-tutorial",
            minSettle: 1.0,
            afterFinnExtra: 0.8,
            maxFinnWait: 5
        )
        #endif
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.duoBlue : Theme.border)
                    .frame(width: index == page ? 22 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: page)
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            Button {
                if page < pages.count - 1 {
                    Haptic.light()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        page += 1
                    }
                } else {
                    finish()
                }
            } label: {
                Text(page < pages.count - 1 ? "NEXT" : "GOT IT")
            }
            .buttonStyle(DuoButtonStyle(tint: .duoBlue, shadowTint: .duoBlueShadow, height: 54))

            if page == pages.count - 1 {
                Text("You can add widgets anytime from the Home Screen or Lock Screen.")
                    .font(AppFont.caption())
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func finish() {
        Haptic.success()
        isPresented = false
    }
}

// MARK: - Pages

private struct WidgetTutorialPage: Identifiable {
    let id = UUID()
    let eyebrow: String
    let title: String
    let subtitle: String
    let preview: AnyView
    let steps: [WidgetTutorialStep]

    static var all: [WidgetTutorialPage] {
        [
            WidgetTutorialPage(
                eyebrow: "WIDGETS",
                title: "Your countdown,\nalways visible",
                subtitle: "See days and hours left without opening the app. Perfect for exam season.",
                preview: AnyView(WidgetTutorialIntroPreview()),
                steps: []
            ),
            WidgetTutorialPage(
                eyebrow: "HOME SCREEN",
                title: "Add a Home Screen widget",
                subtitle: "Pin your next deadline where you glance most often.",
                preview: AnyView(WidgetTutorialHomePreview()),
                steps: [
                    WidgetTutorialStep(number: 1, text: "Touch and hold an empty area on your Home Screen."),
                    WidgetTutorialStep(number: 2, text: "Tap the + button in the top-left corner."),
                    WidgetTutorialStep(number: 3, text: "Search for Deadlinely and pick Small or Medium."),
                    WidgetTutorialStep(number: 4, text: "Tap Add Widget, then Done."),
                ]
            ),
            WidgetTutorialPage(
                eyebrow: "LOCK SCREEN",
                title: "Add a Lock Screen widget",
                subtitle: "A quick read every time you wake your phone.",
                preview: AnyView(WidgetTutorialLockPreview()),
                steps: [
                    WidgetTutorialStep(number: 1, text: "Touch and hold your Lock Screen, then tap Customize."),
                    WidgetTutorialStep(number: 2, text: "Choose your lock screen and tap Add Widgets."),
                    WidgetTutorialStep(number: 3, text: "Search Deadlinely and add rectangular, circular, or inline."),
                    WidgetTutorialStep(number: 4, text: "Tap Done. Your soonest deadline shows by default."),
                ]
            ),
        ]
    }
}

private struct WidgetTutorialStep: Identifiable {
    let id = UUID()
    let number: Int
    let text: String
}

private struct WidgetTutorialPageView: View {
    let page: WidgetTutorialPage

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                Text(page.eyebrow)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(1.0)
                    .foregroundStyle(Color.duoBlue)

                VStack(spacing: 8) {
                    Text(page.title)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text(page.subtitle)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                page.preview
                    .padding(.vertical, 4)

                if !page.steps.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(page.steps.enumerated()), id: \.element.id) { index, step in
                            WidgetTutorialStepRow(step: step)
                            if index < page.steps.count - 1 {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Theme.border, lineWidth: Theme.strokeWidth)
                    )
                }
            }
            .contentWidth()
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}

private struct WidgetTutorialStepRow: View {
    let step: WidgetTutorialStep

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(step.number)")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.duoBlue))

            Text(step.text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - Previews

private enum WidgetTutorialStyle {
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.95, blue: 1.0),
                Color(red: 0.94, green: 0.96, blue: 1.0),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct WidgetTutorialIntroPreview: View {
    private let sample = WidgetTutorialWidgetSample.standard

    var body: some View {
        GeometryReader { geometry in
            let mediumWidth = min(geometry.size.width - 24, 338)
            let mediumHeight = mediumWidth * 155 / 338
            let smallSize: CGFloat = min(158, geometry.size.width * 0.42)

            ZStack {
                WidgetTutorialRealHomeMediumView(sample: sample)
                    .frame(width: mediumWidth, height: mediumHeight)
                    .shadow(color: Color.black.opacity(0.12), radius: 14, y: 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .offset(x: 4, y: 6)

                WidgetTutorialRealHomeSmallView(sample: sample)
                    .frame(width: smallSize, height: smallSize)
                    .shadow(color: Color.black.opacity(0.12), radius: 12, y: 6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: -4, y: -4)
            }
        }
        .frame(height: 252)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

private struct WidgetTutorialHomePreview: View {
    private let sample = WidgetTutorialWidgetSample.standard

    var body: some View {
        WidgetTutorialRealHomeMediumView(sample: sample)
            .frame(width: 338, height: 158)
            .shadow(color: Color.black.opacity(0.1), radius: 16, y: 8)
    }
}

private struct WidgetTutorialLockPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            WidgetTutorialLockRect()
                .frame(maxWidth: .infinity)
                .frame(height: 64)
            HStack(spacing: 12) {
                WidgetTutorialLockCircle()
                WidgetTutorialLockInline()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.88))
        )
        .shadow(color: Color.black.opacity(0.15), radius: 16, y: 8)
    }
}

private struct WidgetTutorialLockRect: View {
    private let accent = Color(red: 0.34, green: 0.78, blue: 0.42)

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Final Exam")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text("12d 4h")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accent.opacity(0.2))
        )
    }
}

private struct WidgetTutorialLockCircle: View {
    private let accent = Color(red: 0.34, green: 0.78, blue: 0.42)

    var body: some View {
        VStack(spacing: 0) {
            Text("12")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
            Text("days")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(accent)
        .frame(width: 58, height: 58)
        .background(Circle().fill(accent.opacity(0.2)))
    }
}

private struct WidgetTutorialLockInline: View {
    var body: some View {
        Text("Final Exam · 12d")
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Capsule().fill(Color.white.opacity(0.12))
            )
    }
}
