import XCTest
import MandarinCore

final class DailyPlanTests: XCTestCase {
    func testDailyPlanGenerationReturnsStableDayPlan() {
        let planner = DailyPlanService()
        let user = UserProfile(hasCompletedOnboarding: true)
        let plan = planner.plan(for: Date(timeIntervalSince1970: 1_719_043_200), user: user, entries: [Fixtures.entry], existingPlan: nil)
        XCTAssertEqual(plan.goalCount, user.dailyGoal)
        XCTAssertEqual(plan.featuredEntryId, Fixtures.entry.id)
    }

    func testWidgetStateEncodesAndDecodes() throws {
        let state = WidgetState(id: UUID(), userId: UUID(), lastUpdatedAt: .now, featuredEntryId: UUID(), simplified: "你", traditional: "你", displayText: "你", pinyin: "nǐ", shortMeaning: "you", progressText: "2 due", deepLinkURL: "mandarinapp://today", widgetMode: .todayCard)
        let snapshot = WidgetSnapshot(state: state, generatedAt: .now)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(WidgetSnapshot.self, from: data)
        XCTAssertEqual(decoded.state, state)
    }
}
