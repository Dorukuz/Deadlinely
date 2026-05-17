import Foundation
import RevenueCat

@MainActor
@Observable
final class RevenueCatService {
    static let shared = RevenueCatService()

    private(set) var isPro = false
    private(set) var shouldPresentProWelcome = false
    private(set) var offerings: Offerings?
    private(set) var isLoading = false
    private(set) var lastError: String?
    private(set) var welcomeIntroEligibility: IntroEligibilityStatus = .unknown

    private var configured = false

    var isWelcomeIntroEligible: Bool {
        welcomeIntroEligibility == .eligible
    }

    func configure() {
        guard !configured else { return }
        configured = true
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: apiKey)
        Purchases.shared.delegate = RevenueCatPurchasesDelegate.shared
        Task { await refreshCustomerInfo() }
    }

    func refreshOfferings() async {
        isLoading = true
        defer { isLoading = false }
        do {
            offerings = try await Purchases.shared.offerings()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshWelcomeIntroEligibility() async {
        let result = await Purchases.shared.checkTrialOrIntroDiscountEligibility(
            productIdentifiers: [AppConstants.secretOfferMonthlyProductID]
        )
        welcomeIntroEligibility = result[AppConstants.secretOfferMonthlyProductID]?.status ?? .unknown
    }

    func refreshSecretOfferState() async {
        await refreshOfferings()
        await refreshWelcomeIntroEligibility()
    }

    func acknowledgeProWelcome() {
        shouldPresentProWelcome = false
        UserDefaults.standard.set(true, forKey: AppConstants.hasShownProWelcomeKey)
    }

    #if DEBUG
    func applyCustomerInfoForScreenshotPreview() {
        isPro = true
        queueProWelcomeIfNeeded()
    }
    #endif

    func refreshCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            syncProStatus(from: info)
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Main paywall only. Full-price `Deadlinely_Pro_Monthly` / yearly. Never applies welcome or Secret pricing.
    func purchaseStandard(package: Package) async -> Bool {
        guard isStandardPaywallPackage(package) else {
            lastError = "Use the welcome offer screen for discounted monthly pricing."
            return false
        }

        isLoading = true
        defer { isLoading = false }
        do {
            let result: PurchaseResultData
            if package.packageType == .monthly,
               package.storeProduct.productIdentifier == AppConstants.monthlyProductID {
                let product = try await loadStoreProduct(productID: AppConstants.monthlyProductID)
                result = try await Purchases.shared.purchase(product: product)
            } else {
                result = try await Purchases.shared.purchase(package: package)
            }
            return await finishPurchase(result)
        } catch {
            return handlePurchaseError(error)
        }
    }

    /// Secret offer sheet only. Welcome product (new users) or `Secret` promo on standard monthly (lapsed).
    func purchaseSecretOffer(package: Package) async -> Bool {
        guard isSecretOfferPackage(package) else {
            lastError = "This price is only available from the welcome offer."
            return false
        }

        isLoading = true
        defer { isLoading = false }
        do {
            let result: PurchaseResultData
            switch secretOfferKind(for: package) {
            case .introductory:
                result = try await Purchases.shared.purchase(package: package)
            case .promotional:
                guard let discount = secretOfferPromotionalDiscount(for: package) else {
                    lastError = "Welcome offer is not available right now."
                    return false
                }
                let promo = try await Purchases.shared.promotionalOffer(
                    forProductDiscount: discount,
                    product: package.storeProduct
                )
                result = try await Purchases.shared.purchase(package: package, promotionalOffer: promo)
            }
            return await finishPurchase(result)
        } catch {
            return handlePurchaseError(error)
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let info = try await Purchases.shared.restorePurchases()
            syncProStatus(from: info)
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    var standardPackages: [Package] {
        var packages = filterStandardPaywallPackages(packagesFromStandardOffering())
        if let monthly = standardMonthlyPackage {
            packages.removeAll { $0.packageType == .monthly }
            packages.append(monthly)
        }
        return packages.sorted { lhs, rhs in
            planRank(lhs.packageType) < planRank(rhs.packageType)
        }
    }

    var secretOfferMonthlyPackage: Package? {
        secretOfferPackages.first
    }

    var secretOfferPackages: [Package] {
        if let package = packageFromDiscountOffering() {
            return [package]
        }

        let matches = allSecretOfferPackages()
            .filter { $0.storeProduct.productIdentifier == AppConstants.secretOfferMonthlyProductID }
        if !matches.isEmpty { return matches }

        return []
    }

    /// `discount` offering → `$rc_monthly` → `Deadlinely_Pro_Secret`.
    private func packageFromDiscountOffering() -> Package? {
        guard let offering = offerings?.offering(identifier: AppConstants.secretOfferOfferingID) else {
            return nil
        }

        if let package = offering.package(identifier: AppConstants.secretOfferPackageIdentifier),
           isSecretOfferPackage(package) {
            return package
        }

        if let monthly = offering.monthly,
           monthly.storeProduct.productIdentifier == AppConstants.secretOfferMonthlyProductID {
            return monthly
        }

        return offering.availablePackages.first(where: isSecretOfferPackage)
    }

    func secretOfferKind(for package: Package) -> SecretOfferKind {
        if package.storeProduct.productIdentifier == AppConstants.secretOfferMonthlyProductID {
            return .introductory
        }
        return .promotional
    }

    func secretOfferPromotionalDiscount(for package: Package) -> StoreProductDiscount? {
        guard package.storeProduct.productIdentifier == AppConstants.monthlyProductID else { return nil }
        return package.storeProduct.discounts.first {
            $0.offerIdentifier == AppConstants.secretOfferPromotionalOfferID
        }
    }

    var standardMonthlyPackage: Package? {
        allStandardMonthlyPackages().max(by: { priceValue($0) < priceValue($1) })
    }

    func isSecretOfferPackage(_ package: Package) -> Bool {
        let productID = package.storeProduct.productIdentifier
        if productID == AppConstants.secretOfferMonthlyProductID { return true }
        if productID == AppConstants.monthlyProductID, secretOfferPromotionalDiscount(for: package) != nil {
            return true
        }
        return false
    }

    func isStandardPaywallPackage(_ package: Package) -> Bool {
        !isSecretOfferPackage(package)
    }

    // MARK: - Private

    private func packagesFromStandardOffering() -> [Package] {
        if let packages = packages(from: AppConstants.standardOfferingID), !packages.isEmpty {
            return packages
        }

        if let offerings {
            for (identifier, offering) in offerings.all where identifier != AppConstants.secretOfferOfferingID {
                let packages = offering.availablePackages
                if !packages.isEmpty { return packages }
            }
        }

        if offerings?.current?.identifier != AppConstants.secretOfferOfferingID {
            return offerings?.current?.availablePackages ?? []
        }

        return []
    }

    private func filterStandardPaywallPackages(_ packages: [Package]) -> [Package] {
        packages.filter(isStandardPaywallPackage)
    }

    private func allStandardMonthlyPackages() -> [Package] {
        guard let offerings else { return [] }
        return offerings.all.values
            .flatMap(\.availablePackages)
            .filter {
                $0.packageType == .monthly
                    && $0.storeProduct.productIdentifier == AppConstants.monthlyProductID
            }
    }

    private func allSecretOfferPackages() -> [Package] {
        guard let offerings else { return [] }
        return offerings.all.values
            .flatMap(\.availablePackages)
            .filter(isSecretOfferPackage)
    }

    private func packages(from offeringID: String) -> [Package]? {
        offerings?.offering(identifier: offeringID)?.availablePackages
    }

    private func loadStoreProduct(productID: String) async throws -> StoreProduct {
        let products = await Purchases.shared.products([productID])
        if let product = products.first { return product }
        throw RevenueCatError.productNotFound
    }

    private func priceValue(_ package: Package) -> Double {
        NSDecimalNumber(decimal: package.storeProduct.price as Decimal).doubleValue
    }

    private func planRank(_ type: PackageType) -> Int {
        switch type {
        case .annual: 0
        case .monthly: 1
        default: 2
        }
    }

    @discardableResult
    private func finishPurchase(_ result: PurchaseResultData) async -> Bool {
        if result.userCancelled { return false }

        syncProStatus(from: result.customerInfo)
        lastError = nil
        if isPro {
            queueProWelcomeIfNeeded()
            return true
        }

        // Entitlement can lag behind a successful StoreKit transaction.
        try? await Task.sleep(for: .milliseconds(400))
        await refreshCustomerInfo()
        if isPro {
            queueProWelcomeIfNeeded()
        }
        return isPro
    }

    private func queueProWelcomeIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: AppConstants.hasShownProWelcomeKey) else { return }
        shouldPresentProWelcome = true
    }

    func applyCustomerInfo(_ info: CustomerInfo) {
        syncProStatus(from: info)
    }

    private func syncProStatus(from info: CustomerInfo) {
        isPro = hasUnlockedProAccess(in: info)
    }

    private func hasUnlockedProAccess(in info: CustomerInfo) -> Bool {
        if info.entitlements[AppConstants.proEntitlementID]?.isActive == true {
            return true
        }

        let proProductIDs: Set<String> = [
            AppConstants.monthlyProductID,
            AppConstants.yearlyProductID,
            AppConstants.secretOfferMonthlyProductID,
        ]

        return !info.activeSubscriptions.intersection(proProductIDs).isEmpty
    }

    private func handlePurchaseError(_ error: Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain != ErrorCode.errorDomain || nsError.code != ErrorCode.purchaseCancelledError.rawValue {
            lastError = error.localizedDescription
        }
        return false
    }

    private var apiKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String, !key.isEmpty {
            return key
        }
        return "appl_MyTueGRMFbfKmViMEGPJmepZxJa"
    }
}

enum SecretOfferKind: Equatable {
    case promotional
    case introductory
}

private enum RevenueCatError: LocalizedError {
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            "Monthly subscription could not be loaded. Try again."
        }
    }
}
