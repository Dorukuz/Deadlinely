import Foundation
import SwiftData

enum ModelContainerFactory {
    static let schema = Schema(versionedSchema: DeadlinelySchemaV2.self)

    static func makeContainer() throws -> ModelContainer {
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupID
        ) {
            let storeURL = groupURL.appending(path: "Deadlinely.store")
            return try makeContainer(storeURL: storeURL)
        }
        return try ModelContainer(
            for: schema,
            migrationPlan: DeadlinelyMigrationPlan.self
        )
    }

    private static func makeContainer(storeURL: URL) throws -> ModelContainer {
        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: DeadlinelyMigrationPlan.self,
                configurations: [config]
            )
        } catch {
            try removeStoreFiles(at: storeURL)
            return try ModelContainer(
                for: schema,
                migrationPlan: DeadlinelyMigrationPlan.self,
                configurations: [config]
            )
        }
    }

    private static func removeStoreFiles(at storeURL: URL) throws {
        let fm = FileManager.default
        let candidates: [URL] = [
            storeURL,
            storeURL.appendingPathExtension("sqlite"),
            storeURL.appendingPathExtension("sqlite-shm"),
            storeURL.appendingPathExtension("sqlite-wal"),
        ]
        for url in candidates where fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
    }

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: AppConstants.appGroupID)
    }
}
