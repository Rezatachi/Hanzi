import Foundation

public struct WidgetSnapshot: Codable, Sendable, Equatable {
    public var state: WidgetState
    public var generatedAt: Date

    public init(state: WidgetState, generatedAt: Date) {
        self.state = state
        self.generatedAt = generatedAt
    }
}

public protocol WidgetStateWriting: Sendable {
    func write(_ state: WidgetState) throws
    func read() throws -> WidgetState?
}

public struct AppGroupWidgetStateStore: WidgetStateWriting {
    public static let appGroupIdentifier = "group.com.example.mandarindrift.shared"
    public static let filename = "widget-state.json"

    public init() {}

    public func write(_ state: WidgetState) throws {
        guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier) else { return }
        let url = directory.appendingPathComponent(Self.filename)
        let data = try JSONEncoder.shared.encode(WidgetSnapshot(state: state, generatedAt: .now))
        try data.write(to: url, options: .atomic)
    }

    public func read() throws -> WidgetState? {
        guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier) else { return nil }
        let url = directory.appendingPathComponent(Self.filename)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try JSONDecoder.shared.decode(WidgetSnapshot.self, from: data).state
    }
}

public struct WidgetStateService {
    private let store: WidgetStateWriting

    public init(store: WidgetStateWriting = AppGroupWidgetStateStore()) {
        self.store = store
    }

    public func makeState(
        plan: DailyPlan,
        entry: HanziEntry,
        progressText: String,
        mode: WidgetMode
    ) -> WidgetState {
        WidgetState(
            id: UUID(),
            userId: plan.userId,
            lastUpdatedAt: .now,
            featuredEntryId: entry.id,
            simplified: entry.simplified,
            traditional: entry.traditional,
            displayText: entry.simplified,
            pinyin: entry.pinyin,
            shortMeaning: entry.shortDefinition,
            progressText: progressText,
            deepLinkURL: "mandarinapp://card/\(entry.id.uuidString)",
            widgetMode: mode
        )
    }

    public func write(_ state: WidgetState) throws {
        try store.write(state)
    }

    public func read() throws -> WidgetState? {
        try store.read()
    }
}

private extension JSONEncoder {
    static let shared: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
}

private extension JSONDecoder {
    static let shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
