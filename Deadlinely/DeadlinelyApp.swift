import SwiftData
import SwiftUI
import UIKit

@main
struct DeadlinelyApp: App {
    let container: ModelContainer

    init() {
        DeadlinelyAppearance.configure()
        RevenueCatService.shared.configure()
        do {
            container = try ModelContainerFactory.makeContainer()
            #if DEBUG
            if ScreenshotLaunchHelper.activeMode != nil {
                let context = ModelContext(container)
                ScreenshotLaunchHelper.configureIfNeeded(modelContext: context)
                try? context.save()
            }
            #endif
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
