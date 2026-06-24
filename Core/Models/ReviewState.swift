import Foundation

public enum ReviewCardState: String, Codable, CaseIterable, Sendable {
    case new
    case learning
    case review
    case mastered
    case suspended
    case removed
}

public enum ReviewGrade: String, Codable, CaseIterable, Sendable, Identifiable {
    case again
    case hard
    case good
    case easy

    public var id: String { rawValue }
}

public struct ReviewState: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var entryId: UUID
    public var userId: UUID
    public var state: ReviewCardState
    public var dueAt: Date
    public var intervalDays: Double
    public var easeFactor: Double
    public var repetitions: Int
    public var lapses: Int
    public var lastReviewedAt: Date?
    public var lastGrade: ReviewGrade?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        entryId: UUID,
        userId: UUID,
        state: ReviewCardState = .new,
        dueAt: Date = .now,
        intervalDays: Double = 0,
        easeFactor: Double = 2.5,
        repetitions: Int = 0,
        lapses: Int = 0,
        lastReviewedAt: Date? = nil,
        lastGrade: ReviewGrade? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.entryId = entryId
        self.userId = userId
        self.state = state
        self.dueAt = dueAt
        self.intervalDays = intervalDays
        self.easeFactor = easeFactor
        self.repetitions = repetitions
        self.lapses = lapses
        self.lastReviewedAt = lastReviewedAt
        self.lastGrade = lastGrade
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
