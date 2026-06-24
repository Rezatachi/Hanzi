import Foundation
import MandarinCore
import WidgetKit

@MainActor
final class AppModel: ObservableObject {
    @Published var isLoading = true
    @Published var profile = UserProfile()
    @Published var entries: [HanziEntry] = []
    @Published var reviewStates: [ReviewState] = []
    @Published var reviewLogs: [ReviewLog] = []
    @Published var savedEntries: [SavedEntry] = []
    @Published var currentPlan: DailyPlan?
    @Published var subscription = SubscriptionState()
    @Published var products: [PaywallProduct] = []
    @Published var searchResults: [SearchResult] = []
    @Published var progress = ProgressSnapshot(streak: 0, longestStreak: 0, cardsLearned: 0, cardsMastered: 0, reviewsCompleted: 0, averageAccuracy: 0, dueToday: 0, savedCount: 0, weeklyActivity: [], toneWeaknesses: [], categoryProgress: [])
    @Published var widgetMode: WidgetMode = .todayCard
    @Published var errorMessage: String?

    let persistence: PersistenceController
    let seedLoader: SeedContentLoading
    let srs: SRSServicing
    let planner: DailyPlanServicing
    let searchService: SearchServicing
    let speech: MandarinSpeechService
    let notifications: NotificationServicing
    let featureGates: FeatureGating
    let widgetService: WidgetStateService
    let analytics: AnalyticsService
    let storeKit: StoreKitServicing
    let wallpaperRenderer: WallpaperRendering
    let contentUpdates: ContentUpdateService

    init(
        persistence: PersistenceController,
        seedLoader: SeedContentLoading,
        srs: SRSServicing = SRSService(),
        planner: DailyPlanServicing = DailyPlanService(),
        searchService: SearchServicing = SearchService(),
        speech: MandarinSpeechService,
        notifications: NotificationServicing = NotificationService(),
        featureGates: FeatureGating = FeatureGateService(),
        widgetService: WidgetStateService = WidgetStateService(),
        analytics: AnalyticsService = LocalAnalyticsService(),
        storeKit: StoreKitServicing = MockStoreKitService(),
        wallpaperRenderer: WallpaperRendering = WallpaperRenderService(),
        contentUpdates: ContentUpdateService = MockContentUpdateService()
    ) {
        self.persistence = persistence
        self.seedLoader = seedLoader
        self.srs = srs
        self.planner = planner
        self.searchService = searchService
        self.speech = speech
        self.notifications = notifications
        self.featureGates = featureGates
        self.widgetService = widgetService
        self.analytics = analytics
        self.storeKit = storeKit
        self.wallpaperRenderer = wallpaperRenderer
        self.contentUpdates = contentUpdates
    }

    func bootstrap() async {
        defer { isLoading = false }
        do {
            let seedEntries = try seedLoader.loadEntries()
            try await persistence.entries.importSeedIfNeeded(seedEntries)
            let remoteEntries = try? await contentUpdates.fetchUpdatesIfAvailable()
            if let remoteEntries, !remoteEntries.isEmpty {
                try await persistence.entries.importSeedIfNeeded(remoteEntries)
            }
            profile = try await persistence.profiles.load()
            entries = try await persistence.entries.allEntries()
            reviewStates = try await persistence.reviews.allStates()
            reviewLogs = try await persistence.logs.allLogs()
            savedEntries = try await persistence.saved.allSaved()
            subscription = try await persistence.subscriptions.load()
            if entries.isEmpty {
                currentPlan = nil
                refreshSearch(query: "")
                recalculateProgress()
                errorMessage = "No Mandarin entries are available yet. Check your seed content or remote dictionary configuration."
                return
            }
            currentPlan = try await ensureDailyPlan()
            products = try await storeKit.loadProducts()
            refreshSearch(query: "")
            recalculateProgress()
            try updateWidgetState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshLargeDictionary() async {
        do {
            let remoteEntries = try await contentUpdates.fetchUpdatesIfAvailable()
            guard !remoteEntries.isEmpty else { return }
            try await persistence.entries.importSeedIfNeeded(remoteEntries)
            entries = try await persistence.entries.allEntries()
            currentPlan = try await ensureDailyPlan()
            refreshSearch(query: "")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeOnboarding() async {
        profile.hasCompletedOnboarding = true
        await saveProfile()
        _ = try? await ensureDailyPlan()
        await analytics.track(event: .onboardingCompleted, metadata: [:])
    }

    func saveProfile() async {
        do {
            try await persistence.profiles.save(profile)
            recalculateProgress()
            try updateWidgetState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func ensureDailyPlan() async throws -> DailyPlan {
        if let plan = try await persistence.plans.currentPlan(for: profile.id, date: .now) {
            currentPlan = plan
            return plan
        }
        let newPlan = planner.plan(for: .now, user: profile, entries: entries, existingPlan: currentPlan)
        try await persistence.plans.save(newPlan)
        currentPlan = newPlan
        return newPlan
    }

    func featuredEntry() -> HanziEntry? {
        guard let id = currentPlan?.featuredEntryId else { return nil }
        return entries.first { $0.id == id }
    }

    func relatedEntries() -> [HanziEntry] {
        guard let relatedIDs = currentPlan?.relatedEntryIds else { return [] }
        return entries.filter { relatedIDs.contains($0.id) }
    }

    func queue(for mode: StudySessionMode = .review) -> [ReviewQueueItem] {
        srs.dueQueue(entries: filteredEntriesForAccess(), states: reviewStates, userId: profile.id, dailyGoal: profile.dailyGoal, now: .now)
    }

    func grade(entry: HanziEntry, grade: ReviewGrade) async {
        let existing = reviewStates.first(where: { $0.entryId == entry.id }) ?? ReviewState(entryId: entry.id, userId: profile.id)
        let previousDue = existing.dueAt
        let previousInterval = existing.intervalDays
        let result = srs.grade(state: existing, grade: grade, now: .now)
        do {
            try await persistence.reviews.save(result.newState)
            let log = ReviewLog(
                id: UUID(),
                userId: profile.id,
                entryId: entry.id,
                sessionId: nil,
                grade: grade,
                previousDueAt: previousDue,
                nextDueAt: result.nextDueAt,
                previousInterval: previousInterval,
                nextInterval: result.newState.intervalDays,
                createdAt: .now
            )
            try await persistence.logs.append(log)
            reviewStates = try await persistence.reviews.allStates()
            reviewLogs = try await persistence.logs.allLogs()
            currentPlan?.completedReviews += 1
            if existing.state == .new {
                currentPlan?.completedNewCards += 1
            }
            if let currentPlan {
                try await persistence.plans.save(currentPlan)
            }
            recalculateProgress()
            try updateWidgetState()
            await analytics.track(event: .cardReviewed, metadata: ["grade": grade.rawValue])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleSave(entry: HanziEntry) async {
        do {
            if isSaved(entry.id) {
                try await persistence.saved.remove(entryId: entry.id, userId: profile.id)
            } else {
                let limit = await featureGates.freeSavedLimit()
                if subscription.isActive || savedEntries.count < limit {
                    try await persistence.saved.save(SavedEntry(id: UUID(), userId: profile.id, entryId: entry.id, savedAt: .now, note: nil))
                }
            }
            savedEntries = try await persistence.saved.allSaved()
            recalculateProgress()
            try updateWidgetState()
            await analytics.track(event: .cardSaved, metadata: ["entry": entry.simplified])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isSaved(_ entryID: UUID) -> Bool {
        savedEntries.contains { $0.entryId == entryID }
    }

    func removeFromReview(entry: HanziEntry) async {
        guard var state = reviewStates.first(where: { $0.entryId == entry.id }) else { return }
        state.state = .removed
        state.updatedAt = .now
        do {
            try await persistence.reviews.save(state)
            reviewStates = try await persistence.reviews.allStates()
            recalculateProgress()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshSearch(query: String, filter: SearchFilter = .init()) {
        searchResults = searchService.search(
            query: query,
            entries: filteredEntriesForAccess(),
            savedIds: Set(savedEntries.map(\.entryId)),
            dueIds: Set(queue().map(\.entry.id)),
            learnedIds: Set(reviewStates.filter { $0.state == .review || $0.state == .mastered }.map(\.entryId)),
            filter: filter
        )
    }

    func changeSubscription(_ state: SubscriptionState) async {
        subscription = state
        profile.subscriptionTier = state.tier
        do {
            try await persistence.subscriptions.save(state)
            try await persistence.profiles.save(profile)
            entries = try await persistence.entries.allEntries()
            try updateWidgetState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func requestReminderPermission(preset: ReminderPreset) async {
        guard let components = preset.timeComponents else {
            profile.reminderEnabled = false
            profile.reminderTime = nil
            await saveProfile()
            await notifications.clearDailyReminders()
            return
        }
        do {
            let granted = try await notifications.requestAuthorization()
            if granted {
                try await notifications.scheduleDailyReminder(
                    at: components,
                    body: reminderCopy(),
                    deepLink: "mandarinapp://today"
                )
                profile.reminderEnabled = true
                profile.reminderTime = components
            }
            await saveProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(productId: String) async {
        do {
            let entitlement = try await storeKit.purchase(productId: productId)
            await changeSubscription(entitlement)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            let entitlement = try await storeKit.restorePurchases()
            await changeSubscription(entitlement)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func filteredEntriesForAccess() -> [HanziEntry] {
        subscription.isActive ? entries : entries.filter { !$0.isPremium }
    }

    private func reminderCopy() -> String {
        if progress.dueToday > 0 {
            return "\(progress.dueToday) tiny reviews are ready."
        }
        return "Your Mandarin card is ready."
    }

    private func recalculateProgress() {
        let calendar = Calendar.current
        let completedLogs = reviewLogs
        let reviewsCompleted = completedLogs.count
        let cardsLearned = reviewStates.filter { $0.state != .new && $0.state != .removed }.count
        let cardsMastered = reviewStates.filter { $0.state == .mastered }.count
        let correctCount = completedLogs.filter { $0.grade == .good || $0.grade == .easy }.count
        let averageAccuracy = reviewsCompleted == 0 ? 0 : Double(correctCount) / Double(reviewsCompleted)
        let dueToday = queue().filter { calendar.isDateInToday($0.state.dueAt) || $0.state.dueAt < .now }.count
        let weekly = (0..<7).compactMap { offset -> WeeklyActivityPoint? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { return nil }
            let count = completedLogs.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count
            return WeeklyActivityPoint(date: calendar.startOfDay(for: date), reviews: count)
        }.sorted { $0.date < $1.date }
        let streak = weekly.reversed().reduce(into: 0) { partial, point in
            if point.reviews > 0 {
                partial += 1
            } else if partial > 0 {
                return
            }
        }
        let toneWeaknesses = reviewLogs
            .filter { $0.grade == .again || $0.grade == .hard }
            .compactMap { log in entries.first(where: { $0.id == log.entryId })?.toneTip }
            .prefix(3)
            .map { $0 }
        let categoryProgress = LearningCategory.allCases.map { category in
            let total = entries.filter { $0.categories.contains(category) }.count
            let learned = reviewStates.filter { state in
                state.state != .new && entries.first(where: { $0.id == state.entryId })?.categories.contains(category) == true
            }.count
            return CategoryProgress(category: category, learned: learned, total: total)
        }
        progress = ProgressSnapshot(
            streak: streak,
            longestStreak: max(streak, progress.longestStreak),
            cardsLearned: cardsLearned,
            cardsMastered: cardsMastered,
            reviewsCompleted: reviewsCompleted,
            averageAccuracy: averageAccuracy,
            dueToday: dueToday,
            savedCount: savedEntries.count,
            weeklyActivity: weekly,
            toneWeaknesses: toneWeaknesses,
            categoryProgress: categoryProgress.filter { $0.total > 0 }
        )
    }

    private func updateWidgetState() throws {
        guard let plan = currentPlan, let entry = featuredEntry() else { return }
        let widgetState = widgetService.makeState(
            plan: plan,
            entry: entry,
            progressText: "\(progress.dueToday) due",
            mode: widgetMode
        )
        try widgetService.write(widgetState)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
