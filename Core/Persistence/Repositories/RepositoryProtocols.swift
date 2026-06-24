import Foundation

public protocol UserProfileRepository: Sendable {
    func load() async throws -> UserProfile
    func save(_ profile: UserProfile) async throws
}

public protocol HanziEntryRepository: Sendable {
    func allEntries() async throws -> [HanziEntry]
    func entry(id: UUID) async throws -> HanziEntry?
    func importSeedIfNeeded(_ entries: [HanziEntry]) async throws
}

public protocol ReviewStateRepository: Sendable {
    func allStates() async throws -> [ReviewState]
    func state(for entryId: UUID, userId: UUID) async throws -> ReviewState?
    func save(_ state: ReviewState) async throws
    func save(_ states: [ReviewState]) async throws
}

public protocol ReviewLogRepository: Sendable {
    func allLogs() async throws -> [ReviewLog]
    func append(_ log: ReviewLog) async throws
}

public protocol DailyPlanRepository: Sendable {
    func currentPlan(for userId: UUID, date: Date) async throws -> DailyPlan?
    func save(_ plan: DailyPlan) async throws
}

public protocol SavedEntryRepository: Sendable {
    func allSaved() async throws -> [SavedEntry]
    func save(_ entry: SavedEntry) async throws
    func remove(entryId: UUID, userId: UUID) async throws
}

public protocol WidgetStateRepository: Sendable {
    func load() async throws -> WidgetState?
    func save(_ state: WidgetState) async throws
}

public protocol SubscriptionRepository: Sendable {
    func load() async throws -> SubscriptionState
    func save(_ state: SubscriptionState) async throws
}
