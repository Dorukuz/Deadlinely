import AppIntents
import WidgetKit

struct DeadlineEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Deadline")
    static var defaultQuery = DeadlineQuery()

    var id: String
    var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct DeadlineQuery: EntityQuery {
    func entities(for identifiers: [DeadlineEntity.ID]) async throws -> [DeadlineEntity] {
        WidgetDataStore.fetchItems()
            .filter { identifiers.contains($0.id.uuidString) }
            .map { DeadlineEntity(id: $0.id.uuidString, title: $0.title) }
    }

    func suggestedEntities() async throws -> [DeadlineEntity] {
        WidgetDataStore.fetchItems()
            .filter { !$0.isDone && $0.targetDate > .now }
            .map { DeadlineEntity(id: $0.id.uuidString, title: $0.title) }
    }
}

struct SelectDeadlineIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Deadline"
    static var description = IntentDescription("Choose which countdown to show, or leave empty for the soonest.")

    @Parameter(title: "Deadline")
    var deadline: DeadlineEntity?

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: WidgetAppConstants.appGroupID)
        if let deadline {
            defaults?.set(deadline.id, forKey: WidgetAppConstants.widgetPinnedDeadlineKey)
        } else {
            defaults?.removeObject(forKey: WidgetAppConstants.widgetPinnedDeadlineKey)
        }
        return .result()
    }
}
