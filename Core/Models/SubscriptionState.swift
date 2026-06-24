import Foundation

public struct SubscriptionState: Codable, Sendable, Equatable {
    public var tier: SubscriptionTier
    public var isActive: Bool
    public var productId: String?
    public var expirationDate: Date?
    public var renewalStatus: String?
    public var lastVerifiedAt: Date?

    public init(
        tier: SubscriptionTier = .free,
        isActive: Bool = false,
        productId: String? = nil,
        expirationDate: Date? = nil,
        renewalStatus: String? = nil,
        lastVerifiedAt: Date? = nil
    ) {
        self.tier = tier
        self.isActive = isActive
        self.productId = productId
        self.expirationDate = expirationDate
        self.renewalStatus = renewalStatus
        self.lastVerifiedAt = lastVerifiedAt
    }
}
