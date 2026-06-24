import Foundation

public enum WidgetMode: String, Codable, CaseIterable, Sendable, Identifiable {
    case todayCard
    case dueReview
    case savedRandom
    case toneChallenge

    public var id: String { rawValue }
}

public struct WidgetState: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var userId: UUID
    public var lastUpdatedAt: Date
    public var featuredEntryId: UUID
    public var simplified: String
    public var traditional: String
    public var displayText: String
    public var pinyin: String
    public var shortMeaning: String
    public var progressText: String
    public var deepLinkURL: String
    public var widgetMode: WidgetMode

    public init(id: UUID, userId: UUID, lastUpdatedAt: Date, featuredEntryId: UUID, simplified: String, traditional: String, displayText: String, pinyin: String, shortMeaning: String, progressText: String, deepLinkURL: String, widgetMode: WidgetMode) {
        self.id = id
        self.userId = userId
        self.lastUpdatedAt = lastUpdatedAt
        self.featuredEntryId = featuredEntryId
        self.simplified = simplified
        self.traditional = traditional
        self.displayText = displayText
        self.pinyin = pinyin
        self.shortMeaning = shortMeaning
        self.progressText = progressText
        self.deepLinkURL = deepLinkURL
        self.widgetMode = widgetMode
    }
}
