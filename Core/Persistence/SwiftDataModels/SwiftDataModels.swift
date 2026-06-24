import Foundation
import SwiftData

@Model
public final class UserProfileRecord {
    @Attribute(.unique) public var id: UUID
    public var payload: Data

    public init(id: UUID, payload: Data) {
        self.id = id
        self.payload = payload
    }
}

@Model
public final class EntryRecord {
    @Attribute(.unique) public var id: UUID
    public var payload: Data

    public init(id: UUID, payload: Data) {
        self.id = id
        self.payload = payload
    }
}

@Model
public final class ReviewStateRecord {
    @Attribute(.unique) public var id: UUID
    public var payload: Data

    public init(id: UUID, payload: Data) {
        self.id = id
        self.payload = payload
    }
}
