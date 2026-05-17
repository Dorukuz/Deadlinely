import Foundation
import RevenueCat

final class RevenueCatPurchasesDelegate: NSObject, PurchasesDelegate {
    static let shared = RevenueCatPurchasesDelegate()

    private override init() {
        super.init()
    }

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            RevenueCatService.shared.applyCustomerInfo(customerInfo)
        }
    }
}
