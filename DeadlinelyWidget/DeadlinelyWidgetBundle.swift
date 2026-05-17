import SwiftUI
import WidgetKit

@main
struct DeadlinelyWidgetBundle: WidgetBundle {
    var body: some Widget {
        DeadlinelyCountdownWidget()
    }
}

struct DeadlinelyCountdownWidget: Widget {
    let kind = "DeadlinelyCountdownWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectDeadlineIntent.self, provider: DeadlineWidgetProvider()) { entry in
            DeadlineWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("Home Screen and Lock Screen countdown for your next deadline.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline,
        ])
    }
}

struct DeadlinelyCountdownWidget_Previews: PreviewProvider {
    static var previews: some View {
        let sample = DeadlineWidgetEntry(
            date: .now,
            title: "Capstone",
            timeText: "5d 2h",
            heroText: "5d 2h",
            dueText: "May 30 at 9:00 AM",
            inlineText: "Capstone · 5d",
            circularValue: "5",
            circularUnit: "days",
            refreshInterval: 3_600,
            urgency: .yellow,
            isEmpty: false
        )
        DeadlineHomeSmallView(entry: sample)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        DeadlineHomeMediumView(entry: sample)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        DeadlineRectangularView(entry: sample)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
