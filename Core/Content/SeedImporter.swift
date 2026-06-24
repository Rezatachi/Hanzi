import Foundation

public enum SeedImporterError: Error {
    case invalidData
    case contentValidationFailed([ContentValidationIssue])
}

public protocol SeedContentLoading: Sendable {
    func loadEntries() throws -> [HanziEntry]
}

public struct SeedImporter: SeedContentLoading {
    private let bundle: Bundle
    private let resourceName: String

    public init(bundle: Bundle, resourceName: String = "SeedContent") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    public func loadEntries() throws -> [HanziEntry] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw SeedImporterError.invalidData
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let entries = try decoder.decode([HanziEntry].self, from: data)
        let issues = ContentValidator.validate(entries: entries)
        guard issues.isEmpty else {
            throw SeedImporterError.contentValidationFailed(issues)
        }
        return entries
    }
}
