import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleReminders(for item: DeadlineItem) async {
        let center = UNUserNotificationCenter.current()
        await center.removePendingNotificationRequests(withIdentifiers: identifiers(for: item.id))

        guard !item.isDone else { return }

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        if item.reminderDayBefore {
            let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: item.targetDate) ?? item.targetDate
            await schedule(
                id: "\(item.id.uuidString).dayBefore",
                title: item.title,
                body: "Due tomorrow. You've got this.",
                date: dayBefore
            )
        }

        if item.reminderMorningOf {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: item.targetDate)
            components.hour = 9
            components.minute = 0
            if let morning = Calendar.current.date(from: components) {
                await schedule(
                    id: "\(item.id.uuidString).morning",
                    title: item.title,
                    body: "It's go-time today.",
                    date: morning
                )
            }
        }
    }

    func removeReminders(for id: UUID) async {
        await UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers(for: id)
        )
    }

    private func identifiers(for id: UUID) -> [String] {
        ["\(id.uuidString).dayBefore", "\(id.uuidString).morning"]
    }

    private func schedule(id: String, title: String, body: String, date: Date) async {
        guard date > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
