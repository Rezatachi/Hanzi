import Foundation

public struct ReviewLog: Identifiable, Codable, Sendable {
    public var id: UUID
    public var userId: UUID
    public var entryId: UUID
    public var sessionId: UUID?
    public var grade: ReviewGrade
    public var previousDueAt: Date
    public var nextDueAt: Date
    public var previousInterval: Double
    public var nextInterval: Double
    public var createdAt: Date

    public init(id: UUID, userId: UUID, entryId: UUID, sessionId: UUID?, grade: ReviewGrade, previousDueAt: Date, nextDueAt: Date, previousInterval: Double, nextInterval: Double, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.entryId = entryId
        self.sessionId = sessionId
        self.grade = grade
        self.previousDueAt = previousDueAt
        self.nextDueAt = nextDueAt
        self.previousInterval = previousInterval
        self.nextInterval = nextInterval
        self.createdAt = createdAt
    }
}
