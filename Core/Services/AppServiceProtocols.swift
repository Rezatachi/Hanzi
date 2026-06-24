import Foundation

public protocol AuthService: Sendable {
    func currentUserID() async -> UUID
}

public protocol SyncService: Sendable {
    func sync() async throws
}

public protocol ContentUpdateService: Sendable {
    func fetchUpdatesIfAvailable() async throws -> [HanziEntry]
}

public enum ChineseDictionaryRemoteFormat: String, Sendable {
    case json
    case cedict
}

public enum ContentUpdateServiceError: Error {
    case missingConfiguration
    case invalidResponse
}

public struct RemoteChineseDictionaryConfig: Sendable {
    public let url: URL
    public let format: ChineseDictionaryRemoteFormat
    public let bearerToken: String?
    public let requestTimeout: TimeInterval
    public let importLimit: Int?

    public init(
        url: URL,
        format: ChineseDictionaryRemoteFormat,
        bearerToken: String? = nil,
        requestTimeout: TimeInterval = 20,
        importLimit: Int? = 5000
    ) {
        self.url = url
        self.format = format
        self.bearerToken = bearerToken
        self.requestTimeout = requestTimeout
        self.importLimit = importLimit
    }
}

public struct LocalAuthService: AuthService {
    private let id: UUID
    public init(id: UUID = UUID()) { self.id = id }
    public func currentUserID() async -> UUID { id }
}

public struct MockSyncService: SyncService {
    public init() {}
    public func sync() async throws {}
}

public struct MockContentUpdateService: ContentUpdateService {
    public init() {}
    public func fetchUpdatesIfAvailable() async throws -> [HanziEntry] { [] }
}

public struct RemoteChineseDictionaryService: ContentUpdateService {
    private let config: RemoteChineseDictionaryConfig
    private let session: URLSession
    private let parser: CEDICTParser

    public init(
        config: RemoteChineseDictionaryConfig,
        session: URLSession = .shared,
        parser: CEDICTParser = CEDICTParser()
    ) {
        self.config = config
        self.session = session
        self.parser = parser
    }

    public func fetchUpdatesIfAvailable() async throws -> [HanziEntry] {
        var request = URLRequest(url: config.url)
        request.timeoutInterval = config.requestTimeout
        if let bearerToken = config.bearerToken, !bearerToken.isEmpty {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ContentUpdateServiceError.invalidResponse
        }

        switch config.format {
        case .json:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let wrapper = try? decoder.decode(DictionaryUpdateResponse.self, from: data) {
                return wrapper.items
            }
            return try decoder.decode([HanziEntry].self, from: data)
        case .cedict:
            return try parser.parse(data: data, limit: config.importLimit)
        }
    }
}

private struct DictionaryUpdateResponse: Decodable {
    let items: [HanziEntry]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([HanziEntry].self, forKey: .items) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case items
    }
}
