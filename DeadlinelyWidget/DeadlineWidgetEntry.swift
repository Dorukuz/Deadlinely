import WidgetKit

struct DeadlineWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let timeText: String
    let heroText: String
    let dueText: String
    let inlineText: String
    let circularValue: String
    let circularUnit: String
    let refreshInterval: TimeInterval
    let urgency: WidgetUrgency
    let isEmpty: Bool
}

struct DeadlineWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = DeadlineWidgetEntry
    typealias Intent = SelectDeadlineIntent

    func placeholder(in context: Context) -> DeadlineWidgetEntry {
        sampleEntry
    }

    func snapshot(for configuration: SelectDeadlineIntent, in context: Context) async -> DeadlineWidgetEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: SelectDeadlineIntent, in context: Context) async -> Timeline<DeadlineWidgetEntry> {
        let entry = entry(for: configuration)
        let refresh = entry.refreshInterval
        let nextUpdate = Date().addingTimeInterval(refresh)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func entry(for configuration: SelectDeadlineIntent) -> DeadlineWidgetEntry {
        if let configuredID = configuration.deadline?.id,
           UUID(uuidString: configuredID) != nil {
            UserDefaults(suiteName: WidgetAppConstants.appGroupID)?
                .set(configuredID, forKey: WidgetAppConstants.widgetPinnedDeadlineKey)
        }

        guard let item = WidgetDataStore.resolve() else {
            return DeadlineWidgetEntry(
                date: .now,
                title: "Deadlinely",
                timeText: "Add a date",
                heroText: "Add one",
                dueText: "Open app to add one",
                inlineText: "No deadlines",
                circularValue: "+",
                circularUnit: "",
                refreshInterval: 3_600,
                urgency: .green,
                isEmpty: true
            )
        }

        let remaining = WidgetTimeRemaining(from: item.targetDate)
        let urgency = WidgetUrgency(timeRemaining: item.targetDate.timeIntervalSinceNow)
        let dueText = item.targetDate.formatted(date: .abbreviated, time: .shortened)
        return DeadlineWidgetEntry(
            date: .now,
            title: item.title,
            timeText: remaining.compactDaysHours,
            heroText: remaining.heroCountdown,
            dueText: dueText,
            inlineText: "\(item.title) · \(remaining.compactDaysHours)",
            circularValue: remaining.circularValue,
            circularUnit: remaining.circularUnit,
            refreshInterval: remaining.isUnderOneHour ? 60 : 3_600,
            urgency: urgency,
            isEmpty: false
        )
    }

    private var sampleEntry: DeadlineWidgetEntry {
        DeadlineWidgetEntry(
            date: .now,
            title: "Final Exam",
            timeText: "12d 4h",
            heroText: "12d 4h",
            dueText: "May 30, 2026 at 9:00 AM",
            inlineText: "Final Exam · 12d",
            circularValue: "12",
            circularUnit: "days",
            refreshInterval: 3_600,
            urgency: .green,
            isEmpty: false
        )
    }
}
