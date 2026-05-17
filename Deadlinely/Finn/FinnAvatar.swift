import SwiftUI

struct FinnAvatar: View {
    var pose: FinnPose
    var size: CGFloat
    var animated: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(pose: FinnPose = .wave, size: CGFloat, animated: Bool = true) {
        self.pose = pose
        self.size = size
        self.animated = animated
    }

    var body: some View {
        Group {
            if animated, reduceMotion == false, let url = pose.bundleURL {
                ZStack {
                    if hasMascotAsset {
                        Image("FinnMascot")
                            .resizable()
                            .scaledToFit()
                    }
                    FrameAnimationPlayer(url: url, targetPixelSize: max(size * 3, 360))
                        .id(pose)
                }
            } else if hasMascotAsset {
                Image("FinnMascot")
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Theme.primaryBlue.opacity(0.08))
                Image(systemName: "hare.fill")
                    .font(.system(size: size * 0.35, weight: .semibold))
                    .foregroundStyle(Theme.primaryBlue.opacity(0.35))
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Finn the Deadlinely mascot")
    }

    private var hasMascotAsset: Bool {
        UIImage(named: "FinnMascot") != nil
    }
}
