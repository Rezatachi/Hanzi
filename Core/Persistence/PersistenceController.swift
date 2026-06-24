import Foundation

public struct PersistenceController: Sendable {
    public let profiles: UserProfileRepository
    public let entries: HanziEntryRepository
    public let reviews: ReviewStateRepository
    public let logs: ReviewLogRepository
    public let plans: DailyPlanRepository
    public let saved: SavedEntryRepository
    public let widget: WidgetStateRepository
    public let subscriptions: SubscriptionRepository

    public init(
        profiles: UserProfileRepository,
        entries: HanziEntryRepository,
        reviews: ReviewStateRepository,
        logs: ReviewLogRepository,
        plans: DailyPlanRepository,
        saved: SavedEntryRepository,
        widget: WidgetStateRepository,
        subscriptions: SubscriptionRepository
    ) {
        self.profiles = profiles
        self.entries = entries
        self.reviews = reviews
        self.logs = logs
        self.plans = plans
        self.saved = saved
        self.widget = widget
        self.subscriptions = subscriptions
    }

    public static func preview(entries: [HanziEntry] = []) -> PersistenceController {
        PersistenceController(
            profiles: InMemoryUserProfileRepository(profile: UserProfile(hasCompletedOnboarding: true)),
            entries: InMemoryHanziEntryRepository(entries: entries),
            reviews: InMemoryReviewStateRepository(),
            logs: InMemoryReviewLogRepository(),
            plans: InMemoryDailyPlanRepository(),
            saved: InMemorySavedEntryRepository(),
            widget: InMemoryWidgetStateRepository(),
            subscriptions: InMemorySubscriptionRepository()
        )
    }
}
