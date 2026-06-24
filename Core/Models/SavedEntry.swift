import Foundation

public struct SavedEntry: Identifiable, Codable, Sendable, Hashable {
    public var id: UUID
    public var userId: UUID
    public var entryId: UUID
    public var savedAt: Date
    public var note: String?

    public init(id: UUID, userId: UUID, entryId: UUID, savedAt: Date, note: String?) {
        self.id = id
        self.userId = userId
        self.entryId = entryId
        self.savedAt = savedAt
        self.note = note
    }
}
