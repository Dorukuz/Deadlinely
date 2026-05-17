import Foundation
import SwiftData

enum DeadlineLimitService {
    static func canAddDeadline(count: Int, isPro: Bool) -> Bool {
        isPro || count < AppConstants.freeDeadlineLimit
    }
}
