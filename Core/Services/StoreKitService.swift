import Foundation
import StoreKit

public struct PaywallProduct: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let displayPrice: String

    public init(id: String, title: String, subtitle: String, displayPrice: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.displayPrice = displayPrice
    }
}

public protocol EntitlementVerificationService: Sendable {
    func currentEntitlement() async throws -> SubscriptionState
}

public protocol StoreKitServicing: EntitlementVerificationService, Sendable {
    func loadProducts() async throws -> [PaywallProduct]
    func purchase(productId: String) async throws -> SubscriptionState
    func restorePurchases() async throws -> SubscriptionState
}

public actor StoreKitService: StoreKitServicing {
    public static let monthlyProductId = "com.example.mandarindrift.premium.monthly"
    public static let yearlyProductId = "com.example.mandarindrift.premium.yearly"
    public static let lifetimeProductId = "com.example.mandarindrift.premium.lifetime"

    private let productIds = [monthlyProductId, yearlyProductId, lifetimeProductId]

    public init() {}

    public func loadProducts() async throws -> [PaywallProduct] {
        let products = try await Product.products(for: productIds)
        return products.map {
            PaywallProduct(
                id: $0.id,
                title: $0.displayName,
                subtitle: $0.description,
                displayPrice: $0.displayPrice
            )
        }
        .sorted { $0.id < $1.id }
    }

    public func purchase(productId: String) async throws -> SubscriptionState {
        let products = try await Product.products(for: [productId])
        guard let product = products.first else { return .init() }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return try await currentEntitlement()
        case .userCancelled, .pending:
            return try await currentEntitlement()
        @unknown default:
            return try await currentEntitlement()
        }
    }

    public func restorePurchases() async throws -> SubscriptionState {
        try await AppStore.sync()
        return try await currentEntitlement()
    }

    public func currentEntitlement() async throws -> SubscriptionState {
        for await result in Transaction.currentEntitlements {
            let transaction = try checkVerified(result)
            if transaction.productID.contains("lifetime") {
                return SubscriptionState(tier: .lifetime, isActive: true, productId: transaction.productID, expirationDate: nil, renewalStatus: "lifetime", lastVerifiedAt: .now)
            }
            return SubscriptionState(tier: .premium, isActive: true, productId: transaction.productID, expirationDate: transaction.expirationDate, renewalStatus: "active", lastVerifiedAt: .now)
        }
        return SubscriptionState(tier: .free, isActive: false, productId: nil, expirationDate: nil, renewalStatus: "inactive", lastVerifiedAt: .now)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let signedType):
            return signedType
        }
    }
}

public enum StoreKitError: Error {
    case failedVerification
}

public struct MockStoreKitService: StoreKitServicing {
    private let state: SubscriptionState
    private let products: [PaywallProduct]

    public init(
        state: SubscriptionState = .init(),
        products: [PaywallProduct] = [
            .init(id: StoreKitService.monthlyProductId, title: "Premium Monthly", subtitle: "Unlimited reviews and all widgets.", displayPrice: "$4.99"),
            .init(id: StoreKitService.yearlyProductId, title: "Premium Yearly", subtitle: "Best value for daily learners.", displayPrice: "$39.99"),
            .init(id: StoreKitService.lifetimeProductId, title: "Premium Lifetime", subtitle: "One-time unlock.", displayPrice: "$89.99")
        ]
    ) {
        self.state = state
        self.products = products
    }

    public func loadProducts() async throws -> [PaywallProduct] { products }
    public func purchase(productId: String) async throws -> SubscriptionState { state }
    public func restorePurchases() async throws -> SubscriptionState { state }
    public func currentEntitlement() async throws -> SubscriptionState { state }
}
