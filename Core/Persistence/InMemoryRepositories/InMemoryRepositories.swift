import Foundation

public actor InMemoryUserProfileRepository: UserProfileRepository {
    private var profile: UserProfile

    public init(profile: UserProfile = UserProfile()) {
        self.profile = profile
    }

    public func load() async throws -> UserProfile { profile }
    public func save(_ profile: UserProfile) async throws { self.profile = profile }
}

public actor InMemoryHanziEntryRepository: HanziEntryRepository {
    private var entries: [UUID: HanziEntry] = [:]

    public init(entries: [HanziEntry] = []) {
        self.entries = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
    }

    public func allEntries() async throws -> [HanziEntry] { entries.values.sorted { $0.simplified < $1.simplified } }
    public func entry(id: UUID) async throws -> HanziEntry? { entries[id] }
    public func importSeedIfNeeded(_ entries: [HanziEntry]) async throws {
        for entry in entries where self.entries[entry.id] == nil {
            self.entries[entry.id] = entry
        }
    }
}

public actor InMemoryReviewStateRepository: ReviewStateRepository {
    private var states: [UUID: ReviewState] = [:]

    public init(states: [ReviewState] = []) {
        self.states = Dictionary(uniqueKeysWithValues: states.map { ($0.entryId, $0) })
    }

    public func allStates() async throws -> [ReviewState] { states.values.sorted { $0.dueAt < $1.dueAt } }
    public func state(for entryId: UUID, userId: UUID) async throws -> ReviewState? { states[entryId] }
    public func save(_ state: ReviewState) async throws { states[state.entryId] = state }
    public func save(_ states: [ReviewState]) async throws {
        for state in states { self.states[state.entryId] = state }
    }
}

public actor InMemoryReviewLogRepository: ReviewLogRepository {
    private var logs: [ReviewLog] = []
    public init(logs: [ReviewLog] = []) { self.logs = logs }
    public func allLogs() async throws -> [ReviewLog] { logs.sorted { $0.createdAt > $1.createdAt } }
    public func append(_ log: ReviewLog) async throws { logs.append(log) }
}

public actor InMemoryDailyPlanRepository: DailyPlanRepository {
    private var plans: [String: DailyPlan] = [:]
    public init() {}

    public func currentPlan(for userId: UUID, date: Date) async throws -> DailyPlan? {
        plans[Self.key(userId: userId, date: date)]
    }

    public func save(_ plan: DailyPlan) async throws {
        plans[Self.key(userId: plan.userId, date: plan.date)] = plan
    }

    private static func key(userId: UUID, date: Date) -> String {
        let formatted = ISO8601DateFormatter().string(from: Calendar.current.startOfDay(for: date))
        return "\(userId.uuidString)-\(formatted)"
    }
}

public actor InMemorySavedEntryRepository: SavedEntryRepository {
    private var saved: [SavedEntry] = []

    public init(saved: [SavedEntry] = []) {
        self.saved = saved
    }

    public func allSaved() async throws -> [SavedEntry] { saved.sorted { $0.savedAt > $1.savedAt } }
    public func save(_ entry: SavedEntry) async throws {
        guard !saved.contains(where: { $0.entryId == entry.entryId && $0.userId == entry.userId }) else { return }
        saved.append(entry)
    }
    public func remove(entryId: UUID, userId: UUID) async throws {
        saved.removeAll { $0.entryId == entryId && $0.userId == userId }
    }
}

public actor InMemoryWidgetStateRepository: WidgetStateRepository {
    private var state: WidgetState?
    public init(state: WidgetState? = nil) { self.state = state }
    public func load() async throws -> WidgetState? { state }
    public func save(_ state: WidgetState) async throws { self.state = state }
}

public actor InMemorySubscriptionRepository: SubscriptionRepository {
    private var state: SubscriptionState
    public init(state: SubscriptionState = .init()) { self.state = state }
    public func load() async throws -> SubscriptionState { state }
    public func save(_ state: SubscriptionState) async throws { self.state = state }
}
