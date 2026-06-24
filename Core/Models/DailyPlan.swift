import Foundation

public struct DailyPlan: Identifiable, Codable, Sendable {
    public var id: UUID
    public var userId: UUID
    public var date: Date
    public var featuredEntryId: UUID
    public var sceneTitle: String
    public var sceneDescription: String
    public var relatedEntryIds: [UUID]
    public var completedNewCards: Int
    public var completedReviews: Int
    public var goalCount: Int

    public init(id: UUID, userId: UUID, date: Date, featuredEntryId: UUID, sceneTitle: String, sceneDescription: String, relatedEntryIds: [UUID], completedNewCards: Int, completedReviews: Int, goalCount: Int) {
        self.id = id
        self.userId = userId
        self.date = date
        self.featuredEntryId = featuredEntryId
        self.sceneTitle = sceneTitle
        self.sceneDescription = sceneDescription
        self.relatedEntryIds = relatedEntryIds
        self.completedNewCards = completedNewCards
        self.completedReviews = completedReviews
        self.goalCount = goalCount
    }
}
