import Foundation

public struct LocalStoreSnapshot: Codable, Sendable {
    public var profile: UserProfile
    public var entries: [HanziEntry]
    public var reviews: [ReviewState]
    public var logs: [ReviewLog]
    public var plans: [DailyPlan]
    public var saved: [SavedEntry]
    public var widgetState: WidgetState?
    public var subscription: SubscriptionState
    public var schemaVersion: Int

    public init(
        profile: UserProfile = UserProfile(),
        entries: [HanziEntry] = [],
        reviews: [ReviewState] = [],
        logs: [ReviewLog] = [],
        plans: [DailyPlan] = [],
        saved: [SavedEntry] = [],
        widgetState: WidgetState? = nil,
        subscription: SubscriptionState = .init(),
        schemaVersion: Int = 1
    ) {
        self.profile = profile
        self.entries = entries
        self.reviews = reviews
        self.logs = logs
        self.plans = plans
        self.saved = saved
        self.widgetState = widgetState
        self.subscription = subscription
        self.schemaVersion = schemaVersion
    }
}

public actor LocalStore {
    private let url: URL
    private var snapshot: LocalStoreSnapshot
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(filename: String = "MandarinDriftStore.json") {
        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        url = baseURL.appendingPathComponent(filename)
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = try? Data(contentsOf: url), let loaded = try? decoder.decode(LocalStoreSnapshot.self, from: data) {
            snapshot = loaded
        } else {
            snapshot = LocalStoreSnapshot()
        }
    }

    public func load() -> LocalStoreSnapshot { snapshot }

    public func update(_ mutate: (inout LocalStoreSnapshot) -> Void) throws {
        mutate(&snapshot)
        let data = try encoder.encode(snapshot)
        try data.write(to: url, options: .atomic)
    }
}

public actor LocalUserProfileRepository: UserProfileRepository {
    private let store: LocalStore
    public init(store: LocalStore) { self.store = store }
    public func load() async throws -> UserProfile { await store.load().profile }
    public func save(_ profile: UserProfile) async throws { try await store.update { $0.profile = profile } }
}

public actor LocalHanziEntryRepository: HanziEntryRepository {
    private let store: LocalStore
    public init(store: LocalStore) { self.store = store }
    public func allEntries() async throws -> [HanziEntry] { await store.load().entries }
    public func entry(id: UUID) async throws -> HanziEntry? { await store.load().entries.first { $0.id == id } }
    public func importSeedIfNeeded(_ entries: [HanziEntry]) async throws {
        try await store.update { snapshot in
            let existing = Dictionary(uniqueKeysWithValues: snapshot.entries.map { ($0.id, $0) })
            let appended = entries.filter { existing[$0.id] == nil }
            snapshot.entries.append(contentsOf: appended)
        }
    }
}

public actor LocalReviewStateRepository: ReviewStateRepository {
    private let store: LocalStore
    public init(store: LocalStore) { self.store = store }
    public func allStates() async throws -> [ReviewState] { await store.load().reviews }
    public func state(for entryId: UUID, userId: UUID) async throws -> ReviewState? { await store.load().reviews.first { $0.entryId == entryId && $0.userId == userId } }
    public func save(_ state: ReviewState) async throws {
        try await store.update { snapshot in
            snapshot.reviews.removeAll { $0.entryId == state.entryId && $0.userId == state.userId }
            snapshot.reviews.append(state)
        }
    }
    public func save(_ states: [ReviewState]) async throws {
        try await store.update { snapshot in
            for state in states {
                snapshot.reviews.removeAll { $0.entryId == state.entryId && $0.userId == state.userId }
                snapshot.reviews.append(state)
            }
        }
    }
}

public actor LocalReviewLogRepository: ReviewLogRepository {
    private let store: LocalStore
    public init(store: LocalStore) { self.store = store }
    public func allLogs() async throws -> [ReviewLog] { await store.load().logs }
    public func append(_ log: ReviewLog) async throws { try await store.update { $0.logs.append(log) } }
}

public actor LocalDailyPlanRepository: DailyPlanRepository {
    private let store: LocalStore
    public init(store: LocalStore) { self.store = store }
    public func currentPlan(for userId: UUID, date: Date) async throws -> DailyPlan? {
        await store.load().plans.first { $0.userId == userId && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    public func save(_ plan: DailyPlan) async throws {
        try await store.update { snapshot in
            snapshot.plans.removeAll { $0.userId == plan.userId && Calendar.current.isDate($0.date, inSameDayAs: plan.date) }
            snapshot.plans.append(plan)
        }
    }
}

public actor LocalSavedEntryRepository: SavedEntryRepository {
    private let store: LocalStore
    public init(store: LocalStore) { self.store = store }
    public func allSaved() async throws -> [SavedEntry] { await store.load().saved }
    public func save(_ entry: SavedEntry) async throws {
        try await store.update { snapshot in
            guard !snapshot.saved.contains(where: { $0.entryId == entry.entryId && $0.userId == entry.userId }) else { return }
            snapshot.saved.append(entry)
        }
    }
    public func remove(entryId: UUID, userId: UUID) async throws {
        try await store.update { $0.saved.removeAll { $0.entryId == entryId && $0.userId == userId } }
    }
}

public actor LocalWidgetStateRepository: WidgetStateRepository {
    private let store: LocalStore
    public init(store: LocalStore) { self.store = store }
    public func load() async throws -> WidgetState? { await store.load().widgetState }
    public func save(_ state: WidgetState) async throws { try await store.update { $0.widgetState = state } }
}

public actor LocalSubscriptionRepository: SubscriptionRepository {
    private let store: LocalStore
    public init(store: LocalStore) { self.store = store }
    public func load() async throws -> SubscriptionState { await store.load().subscription }
    public func save(_ state: SubscriptionState) async throws { try await store.update { $0.subscription = state } }
}
