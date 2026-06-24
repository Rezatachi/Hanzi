import XCTest
import MandarinCore
@testable import MandarinDrift

final class DeepLinkAndFeatureTests: XCTestCase {
    func testDeepLinkParsesCardRoute() {
        let id = UUID()
        let url = URL(string: "mandarinapp://card/\(id.uuidString)")!
        XCTAssertEqual(DeepLinkRouter.route(url: url), .card(id))
    }

    func testDeepLinkParsesSearchRoute() {
        let url = URL(string: "mandarinapp://search?q=nihao")!
        XCTAssertEqual(DeepLinkRouter.route(url: url), .search("nihao"))
    }

    func testFeatureGateFreeVsPremium() async {
        let gates = FeatureGateService(remoteConfig: MockRemoteConfigService(features: [.widgets: false]))
        let free = SubscriptionState(tier: .free, isActive: false, productId: nil, expirationDate: nil, renewalStatus: nil, lastVerifiedAt: nil)
        let premium = SubscriptionState(tier: .premium, isActive: true, productId: "id", expirationDate: nil, renewalStatus: nil, lastVerifiedAt: nil)
        let freeWidgets = await gates.canUseWidgets(subscription: free)
        let premiumUnlimited = await gates.canUseUnlimitedReviews(subscription: premium)
        XCTAssertFalse(freeWidgets)
        XCTAssertTrue(premiumUnlimited)
    }
}
