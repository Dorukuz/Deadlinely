import SwiftUI
import WidgetKit

struct DeadlineWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DeadlineWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            DeadlineHomeSmallView(entry: entry)
        case .systemMedium:
            DeadlineHomeMediumView(entry: entry)
        case .accessoryCircular:
            DeadlineCircularView(entry: entry)
        case .accessoryInline:
            DeadlineInlineView(entry: entry)
        case .accessoryRectangular:
            DeadlineRectangularView(entry: entry)
        default:
            DeadlineHomeSmallView(entry: entry)
        }
    }
}
