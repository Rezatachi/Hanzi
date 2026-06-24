import Foundation

public protocol RemoteConfigService: Sendable {
    func boolValue(for feature: RemoteFeature) async -> Bool
    func intValue(for key: String, defaultValue: Int) async -> Int
}

public struct MockRemoteConfigService: RemoteConfigService {
    private let features: [RemoteFeature: Bool]
    private let ints: [String: Int]

    public init(features: [RemoteFeature: Bool] = [:], ints: [String: Int] = [:]) {
        self.features = features
        self.ints = ints
    }

    public func boolValue(for feature: RemoteFeature) async -> Bool { features[feature] ?? true }
    public func intValue(for key: String, defaultValue: Int) async -> Int { ints[key] ?? defaultValue }
}

public protocol FeatureGating: Sendable {
    func canUseWidgets(subscription: SubscriptionState) async -> Bool
    func canUseUnlimitedReviews(subscription: SubscriptionState) async -> Bool
    func canUseWallpaperGenerator(subscription: SubscriptionState) async -> Bool
    func canUseAdvancedStats(subscription: SubscriptionState) async -> Bool
    func canUseAllDecks(subscription: SubscriptionState) async -> Bool
    func canUseFullDictionary(subscription: SubscriptionState) async -> Bool
    func freeReviewLimit() async -> Int
    func freeSavedLimit() async -> Int
}

public struct FeatureGateService: FeatureGating {
    private let remoteConfig: RemoteConfigService

    public init(remoteConfig: RemoteConfigService = MockRemoteConfigService()) {
        self.remoteConfig = remoteConfig
    }

    public func canUseWidgets(subscription: SubscriptionState) async -> Bool {
        let fallback = await remoteConfig.boolValue(for: .widgets)
        return subscription.isActive || fallback
    }
    public func canUseUnlimitedReviews(subscription: SubscriptionState) async -> Bool { subscription.isActive }
    public func canUseWallpaperGenerator(subscription: SubscriptionState) async -> Bool { subscription.isActive }
    public func canUseAdvancedStats(subscription: SubscriptionState) async -> Bool { subscription.isActive }
    public func canUseAllDecks(subscription: SubscriptionState) async -> Bool { subscription.isActive }
    public func canUseFullDictionary(subscription: SubscriptionState) async -> Bool { subscription.isActive }
    public func freeReviewLimit() async -> Int { await remoteConfig.intValue(for: "freeReviewLimit", defaultValue: 10) }
    public func freeSavedLimit() async -> Int { await remoteConfig.intValue(for: "freeSavedLimit", defaultValue: 20) }
}
