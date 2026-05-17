import Foundation
import SwiftData

// MARK: - V1 (pre “mark as done”)

enum DeadlinelySchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [DeadlineItem.self]
    }

    @Model
    final class DeadlineItem {
        var id: UUID
        var title: String
        var targetDate: Date
        var createdAt: Date
        var reminderDayBefore: Bool
        var reminderMorningOf: Bool

        init(
            id: UUID = UUID(),
            title: String,
            targetDate: Date,
            createdAt: Date = .now,
            reminderDayBefore: Bool = true,
            reminderMorningOf: Bool = true
        ) {
            self.id = id
            self.title = title
            self.targetDate = targetDate
            self.createdAt = createdAt
            self.reminderDayBefore = reminderDayBefore
            self.reminderMorningOf = reminderMorningOf
        }
    }
}

// MARK: - V2 (current)

enum DeadlinelySchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [DeadlineItem.self]
    }
}

// MARK: - Plan

enum DeadlinelyMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [DeadlinelySchemaV1.self, DeadlinelySchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: DeadlinelySchemaV1.self,
        toVersion: DeadlinelySchemaV2.self
    )
}
