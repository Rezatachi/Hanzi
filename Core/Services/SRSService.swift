import Foundation

public struct ScheduledReviewResult: Sendable, Equatable {
    public let newState: ReviewState
    public let nextDueAt: Date
}

public struct ReviewQueueItem: Identifiable, Sendable, Equatable {
    public var id: UUID { entry.id }
    public let entry: HanziEntry
    public let state: ReviewState
    public let priority: Int
}

public protocol SRSServicing: Sendable {
    func grade(state: ReviewState, grade: ReviewGrade, now: Date) -> ScheduledReviewResult
    func dueQueue(
        entries: [HanziEntry],
        states: [ReviewState],
        userId: UUID,
        dailyGoal: Int,
        now: Date
    ) -> [ReviewQueueItem]
}

public struct SRSService: SRSServicing {
    public let minimumEaseFactor = 1.3
    public let masteredThresholdDays = 60.0

    public init() {}

    public func grade(state: ReviewState, grade: ReviewGrade, now: Date = .now) -> ScheduledReviewResult {
        var updated = state
        let previousInterval = max(updated.intervalDays, 0)
        var nextInterval = previousInterval
        var nextState = updated.state
        var ease = max(updated.easeFactor, minimumEaseFactor)

        switch grade {
        case .again:
            nextState = .learning
            nextInterval = 0.02
            ease = max(minimumEaseFactor, ease - 0.2)
            updated.lapses += 1
            updated.repetitions = 0
        case .hard:
            nextState = updated.state == .new ? .learning : updated.state
            nextInterval = max(1, max(previousInterval, 1) * 1.2)
            ease = max(minimumEaseFactor, ease - 0.15)
            updated.repetitions += 1
        case .good:
            nextState = (updated.state == .new || updated.state == .learning) ? .review : updated.state
            if updated.repetitions == 0 {
                nextInterval = 1
            } else if updated.repetitions == 1 {
                nextInterval = 3
            } else {
                nextInterval = max(1, max(previousInterval, 1) * ease)
            }
            updated.repetitions += 1
        case .easy:
            nextState = .review
            if updated.repetitions == 0 {
                nextInterval = 3
            } else {
                nextInterval = max(1, max(previousInterval, 1) * ease * 1.3)
            }
            ease += 0.15
            updated.repetitions += 1
        }

        if nextInterval >= masteredThresholdDays, nextState == .review {
            nextState = .mastered
        }

        updated.state = nextState
        updated.intervalDays = nextInterval
        updated.easeFactor = ease
        updated.lastReviewedAt = now
        updated.lastGrade = grade
        updated.updatedAt = now
        updated.dueAt = now.addingTimeInterval(nextInterval * 86_400)

        return ScheduledReviewResult(newState: updated, nextDueAt: updated.dueAt)
    }

    public func dueQueue(
        entries: [HanziEntry],
        states: [ReviewState],
        userId: UUID,
        dailyGoal: Int,
        now: Date = .now
    ) -> [ReviewQueueItem] {
        let stateMap = Dictionary(uniqueKeysWithValues: states.map { ($0.entryId, $0) })
        var dueItems: [ReviewQueueItem] = []
        var newItems: [ReviewQueueItem] = []

        for entry in entries {
            let state = stateMap[entry.id] ?? ReviewState(entryId: entry.id, userId: userId)
            guard state.state != .removed && state.state != .suspended else { continue }
            let priority = priority(for: state, now: now)
            let item = ReviewQueueItem(entry: entry, state: state, priority: priority)
            if state.dueAt <= now || state.state == .learning {
                dueItems.append(item)
            } else if state.state == .new {
                newItems.append(item)
            }
        }

        let sortedDue = dueItems.sorted {
            if $0.priority == $1.priority {
                return $0.state.dueAt < $1.state.dueAt
            }
            return $0.priority < $1.priority
        }
        let dueCount = sortedDue.count
        let newLimit = max(dailyGoal - dueCount, 0)
        let limitedNew = newItems.sorted { $0.entry.frequencyRank ?? 9999 < $1.entry.frequencyRank ?? 9999 }.prefix(newLimit)
        return sortedDue + limitedNew
    }

    private func priority(for state: ReviewState, now: Date) -> Int {
        if state.dueAt < now.addingTimeInterval(-86_400) { return 0 }
        if state.state == .learning { return 1 }
        if state.state == .review { return state.lapses > 0 ? 2 : 3 }
        if state.state == .new { return 4 }
        return 5
    }
}
