import Foundation

enum FinnPose: String, CaseIterable {
    case wave
    case thinking
    case celebrate
    case sad
    case thumbsUp
    case success
    case loading

    var fileName: String {
        switch self {
        case .wave: "finn-wave"
        case .thinking: "finn-thinking"
        case .celebrate: "finn-celebrate"
        case .sad: "finn-sad"
        case .thumbsUp: "finn-thumbs-up"
        case .success: "finn-success"
        case .loading: "finn-loading-bounce"
        }
    }

    var bundleURL: URL? {
        Bundle.main.url(forResource: fileName, withExtension: "mov", subdirectory: "Resources/Finn")
            ?? Bundle.main.url(forResource: fileName, withExtension: "mov")
    }

    init?(videoName: String) {
        switch videoName {
        case "finn-wave": self = .wave
        case "finn-thinking": self = .thinking
        case "finn-celebrate": self = .celebrate
        case "finn-sad": self = .sad
        case "finn-thumbs-up": self = .thumbsUp
        case "finn-success": self = .success
        case "finn-loading-bounce": self = .loading
        default: return nil
        }
    }
}
