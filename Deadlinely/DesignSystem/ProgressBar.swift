import SwiftUI

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.border.opacity(0.5))
                Capsule()
                    .fill(Theme.primaryBlue)
                    .frame(width: max(8, geo.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: 8)
    }
}
