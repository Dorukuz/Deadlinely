import Foundation
import SwiftData

enum WidgetDeadlineResolver {
    static func resolve(
        from items: [DeadlineItem],
        pinnedID: UUID?
    ) -> DeadlineItem? {
        let active = items.filter { !$0.isDone }
        if let pinnedID,
           let pinned = active.first(where: { $0.id == pinnedID }),
           pinned.targetDate > .now {
            return pinned
        }
        return active
            .filter { $0.targetDate > .now }
            .sorted { $0.targetDate < $1.targetDate }
            .first
    }

    static var pinnedDeadlineID: UUID? {
        guard let raw = ModelContainerFactory.sharedDefaults?.string(forKey: AppConstants.widgetPinnedDeadlineKey) else {
            return nil
        }
        return UUID(uuidString: raw)
    }

    static func setPinnedDeadlineID(_ id: UUID?) {
        let defaults = ModelContainerFactory.sharedDefaults
        if let id {
            defaults?.set(id.uuidString, forKey: AppConstants.widgetPinnedDeadlineKey)
        } else {
            defaults?.removeObject(forKey: AppConstants.widgetPinnedDeadlineKey)
        }
    }
}
