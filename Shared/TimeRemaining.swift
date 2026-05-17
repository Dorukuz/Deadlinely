import Foundation

struct TimeRemaining: Equatable {
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
        if isPast { return "Past due" }
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h" }
        if minutes > 0 { return "\(minutes)m \(seconds)s" }
        return "\(seconds)s"
    }

    var largeDisplay: String {
        if isPast { return "Overdue" }
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return hours == 1 ? "1 hour" : "\(hours) hours" }
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

    var heroSubtitle: String {
        if isPast { return "This date has passed" }
        if isUnderOneHour { return "Counting down to the minute" }
        if days > 0 { return "Days and hours until go-time" }
        return "Hours until go-time"
    }

    var inlineDisplay: String {
        if isPast { return "overdue" }
        if days > 0 { return "\(days)d" }
        if hours > 0 { return "\(hours)h" }
        if minutes > 0 { return "\(minutes)m" }
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
        if days > 0 { return days == 1 ? "day" : "days" }
        if hours > 0 { return hours == 1 ? "hour" : "hours" }
        if minutes > 0 { return "min" }
        return "sec"
    }
}
