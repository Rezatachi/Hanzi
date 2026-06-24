import Foundation

public protocol DailyPlanServicing: Sendable {
    func plan(
        for date: Date,
        user: UserProfile,
        entries: [HanziEntry],
        existingPlan: DailyPlan?
    ) -> DailyPlan
}

public struct DailyPlanService: DailyPlanServicing {
    private let scenes: [(String, String, [LearningCategory])] = [
        ("Cafe Pause", "A quiet cafe scene for useful food and small-talk words.", [.food, .basics]),
        ("Subway Rhythm", "Short travel phrases for movement and timing.", [.transport, .time, .travel]),
        ("Office Desk", "Words for work, meetings, and messages.", [.work, .technology]),
        ("Family Table", "Home and family words with warm, common phrases.", [.family, .food]),
        ("Rain Window", "Weather language and feeling words.", [.weather, .emotions]),
        ("Market Lane", "Shopping and number words for everyday buying.", [.shopping, .numbers]),
        ("Hello Circle", "Introductions and social basics for smooth starts.", [.basics, .family]),
        ("Study Corner", "Reading and school language for steady progress.", [.school, .culture]),
        ("Night Walk", "Travel, directions, and calm recall prompts.", [.travel, .transport]),
        ("Weekend Plan", "Time and activity words for easy recall.", [.time, .basics])
    ]

    public init() {}

    public func plan(
        for date: Date,
        user: UserProfile,
        entries: [HanziEntry],
        existingPlan: DailyPlan?
    ) -> DailyPlan {
        if let existingPlan, Calendar.current.isDate(existingPlan.date, inSameDayAs: date) {
            return existingPlan
        }

        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let scene = scenes[(dayIndex - 1) % scenes.count]
        let focusedEntries = entries.filter { !$0.isPremium || user.subscriptionTier != .free }
        guard let fallbackEntry = (focusedEntries.isEmpty ? entries : focusedEntries).first else {
            return DailyPlan(
                id: UUID(),
                userId: user.id,
                date: Calendar.current.startOfDay(for: date),
                featuredEntryId: UUID(),
                sceneTitle: scene.0,
                sceneDescription: scene.1,
                relatedEntryIds: [],
                completedNewCards: 0,
                completedReviews: 0,
                goalCount: user.dailyGoal
            )
        }
        let matching = focusedEntries.filter { !$0.categories.isDisjoint(with: scene.2) }
        let pool = matching.isEmpty ? (focusedEntries.isEmpty ? [fallbackEntry] : focusedEntries) : matching
        let featured = pool[(dayIndex - 1) % pool.count]
        let related = Array(pool.filter { $0.id != featured.id }.prefix(5))

        return DailyPlan(
            id: UUID(),
            userId: user.id,
            date: Calendar.current.startOfDay(for: date),
            featuredEntryId: featured.id,
            sceneTitle: scene.0,
            sceneDescription: scene.1,
            relatedEntryIds: related.map(\.id),
            completedNewCards: 0,
            completedReviews: 0,
            goalCount: user.dailyGoal
        )
    }
}

private extension Array where Element == LearningCategory {
    func isDisjoint(with other: [LearningCategory]) -> Bool {
        Set(self).isDisjoint(with: Set(other))
    }
}
