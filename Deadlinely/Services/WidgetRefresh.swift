import WidgetKit

enum WidgetRefresh {
    static func reloadCountdowns() {
        WidgetCenter.shared.reloadTimelines(ofKind: "DeadlinelyCountdownWidget")
    }
}
