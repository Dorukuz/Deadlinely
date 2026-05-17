import SwiftUI

enum Urgency: String, CaseIterable {
    case green
    case yellow
    case red
    case purple

    init(timeRemaining: TimeInterval) {
        if timeRemaining < 0 {
            self = .purple
        } else {
            let days = timeRemaining / 86_400
            switch days {
            case ..<3: self = .red
            case ..<7: self = .yellow
            default: self = .green
            }
        }
    }

    var color: Color {
        switch self {
        case .green: Color(red: 0.22, green: 0.78, blue: 0.45)
        case .yellow: Color(red: 0.98, green: 0.78, blue: 0.18)
        case .red: Color(red: 0.95, green: 0.32, blue: 0.32)
        case .purple: Color(red: 0.58, green: 0.42, blue: 0.92)
        }
    }

    var softFill: Color {
        color.opacity(0.12)
    }

    var statusLabel: String {
        switch self {
        case .green: return "ON TRACK"
        case .yellow: return "GETTING CLOSE"
        case .red: return "CRUNCH TIME"
        case .purple: return "PAST DUE"
        }
    }
}
