import SwiftUI

enum AppFont {
    static func headline(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func title(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func button() -> Font {
        .system(size: 15, weight: .heavy, design: .rounded)
    }

    static func caption() -> Font {
        .system(size: 13, weight: .semibold, design: .rounded)
    }
}

struct TrackedButtonLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(AppFont.button())
            .tracking(1.2)
    }
}
