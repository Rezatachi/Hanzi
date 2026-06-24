import Foundation

public enum StudySessionMode: String, Codable, CaseIterable, Sendable {
    case daily
    case review
    case newCards
    case saved
    case searchPractice
    case widgetDeepLink
}

public struct StudySession: Identifiable, Codable, Sendable {
    public var id: UUID
    public var userId: UUID
    public var startedAt: Date
    public var endedAt: Date?
    public var mode: StudySessionMode
    public var reviewedCount: Int
    public var newCount: Int
    public var correctCount: Int
    public var againCount: Int
    public var hardCount: Int
    public var goodCount: Int
    public var easyCount: Int

    public init(id: UUID, userId: UUID, startedAt: Date, endedAt: Date?, mode: StudySessionMode, reviewedCount: Int, newCount: Int, correctCount: Int, againCount: Int, hardCount: Int, goodCount: Int, easyCount: Int) {
        self.id = id
        self.userId = userId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.mode = mode
        self.reviewedCount = reviewedCount
        self.newCount = newCount
        self.correctCount = correctCount
        self.againCount = againCount
        self.hardCount = hardCount
        self.goodCount = goodCount
        self.easyCount = easyCount
    }
}
