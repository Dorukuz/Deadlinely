import Foundation
import SwiftData

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

    var timeRemaining: TimeRemaining {
        TimeRemaining(from: targetDate)
    }

    var urgency: Urgency {
        if isDone { return .green }
        return Urgency(timeRemaining: targetDate.timeIntervalSinceNow)
    }
}
