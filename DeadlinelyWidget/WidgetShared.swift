import Foundation
import SwiftData
import SwiftUI

// Widget-target copies of shared types (widget extension cannot import app module).

enum WidgetAppConstants {
    static let appGroupID = "group.Deadlinely.Deadlinely.shared"
    static let widgetPinnedDeadlineKey = "widgetPinnedDeadlineID"
}

enum WidgetUrgency {
    case green, yellow, red, purple

    init(timeRemaining: TimeInterval) {
        if timeRemaining < 0 { self = .purple }
        else {
            let days = timeRemaining / 86_400
            switch days {
            case ..<3: self = .red
            case ..<7: self = .yellow
            default: self = .green
            }
        }
    }

    var color: Color {
        switch self {
        case .green: Color(red: 0.22, green: 0.78, blue: 0.45)
        case .yellow: Color(red: 0.98, green: 0.78, blue: 0.18)
        case .red: Color(red: 0.95, green: 0.32, blue: 0.32)
        case .purple: Color(red: 0.58, green: 0.42, blue: 0.92)
        }
    }

    var statusLabel: String {
        switch self {
        case .green: return "ON TRACK"
        case .yellow: return "CLOSE"
        case .red: return "CRUNCH"
        case .purple: return "PAST"
        }
    }
}

struct WidgetTimeRemaining {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let totalSeconds: Int
    let isPast: Bool

    init(from targetDate: Date, reference: Date = .now) {
        let interval = targetDate.timeIntervalSince(reference)
        isPast = interval < 0
        let absolute = max(0, Int(abs(interval)))
        totalSeconds = absolute
        days = absolute / 86_400
        hours = (absolute % 86_400) / 3_600
        minutes = (absolute % 3_600) / 60
        seconds = absolute % 60
    }

    var isUnderOneHour: Bool {
        !isPast && totalSeconds < 3_600
    }

    var compactDaysHours: String {
        if isPast { return "Past" }
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h" }
        if minutes > 0 { return "\(minutes)m \(seconds)s" }
        return "\(seconds)s"
    }

    var heroCountdown: String {
        if isPast { return "Overdue" }
        if totalSeconds == 0 { return "Now" }
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        if minutes > 0 { return "\(minutes)m \(seconds)s" }
        return "\(seconds)s"
    }

    var circularValue: String {
        if isPast { return "!" }
        if days > 0 { return "\(days)" }
        if hours > 0 { return "\(hours)" }
        if minutes > 0 { return "\(minutes)" }
        return "\(seconds)"
    }

    var circularUnit: String {
        if isPast { return "due" }
        if days > 0 { return "days" }
        if hours > 0 { return "hrs" }
        if minutes > 0 { return "min" }
        return "sec"
    }
}

// Must match app target schema exactly for shared SwiftData store.
@Model
final class DeadlineItem {
    var id: UUID
    var title: String
    var targetDate: Date
    var createdAt: Date
    var reminderDayBefore: Bool
    var reminderMorningOf: Bool
    var isDone: Bool = false
    var completedAt: Date? = nil

    init(
        id: UUID = UUID(),
        title: String,
        targetDate: Date,
        createdAt: Date = .now,
        reminderDayBefore: Bool = true,
        reminderMorningOf: Bool = true,
        isDone: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.reminderDayBefore = reminderDayBefore
        self.reminderMorningOf = reminderMorningOf
        self.isDone = isDone
        self.completedAt = completedAt
    }
}

enum WidgetDataStore {
    static func fetchItems() -> [DeadlineItem] {
        let schema = Schema([DeadlineItem.self])
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WidgetAppConstants.appGroupID) else {
            return []
        }
        let storeURL = groupURL.appending(path: "Deadlinely.store")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            return []
        }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<DeadlineItem>(sortBy: [SortDescriptor(\.targetDate)])
        return (try? context.fetch(descriptor)) ?? []
    }

    static var pinnedID: UUID? {
        guard let raw = UserDefaults(suiteName: WidgetAppConstants.appGroupID)?
            .string(forKey: WidgetAppConstants.widgetPinnedDeadlineKey) else { return nil }
        return UUID(uuidString: raw)
    }

    static func resolve() -> DeadlineItem? {
        let items = fetchItems().filter { !$0.isDone }
        if let pinnedID,
           let pinned = items.first(where: { $0.id == pinnedID }),
           pinned.targetDate > .now {
            return pinned
        }
        return items.filter { $0.targetDate > .now }.sorted { $0.targetDate < $1.targetDate }.first
    }
}
