import Foundation

public struct ContentValidationIssue: Identifiable, Sendable, Equatable {
    public let id = UUID()
    public let message: String
}

public enum ContentValidator {
    public static func validate(entries: [HanziEntry]) -> [ContentValidationIssue] {
        var issues: [ContentValidationIssue] = []
        var seen: Set<String> = []

        for entry in entries {
            if entry.simplified.isEmpty { issues.append(.init(message: "\(entry.id) missing simplified")) }
            if entry.pinyin.isEmpty { issues.append(.init(message: "\(entry.id) missing pinyin")) }
            if entry.definitions.isEmpty { issues.append(.init(message: "\(entry.id) missing definitions")) }
            if entry.exampleChineseSimplified.isEmpty { issues.append(.init(message: "\(entry.id) missing example Chinese")) }
            if entry.exampleEnglish.isEmpty { issues.append(.init(message: "\(entry.id) missing example English")) }
            if entry.categories.isEmpty { issues.append(.init(message: "\(entry.id) missing categories")) }

            let key = "\(entry.simplified)|\(entry.pinyin)"
            if seen.contains(key) {
                issues.append(.init(message: "Duplicate simplified+pinyin combo: \(key)"))
            } else {
                seen.insert(key)
            }
        }

        return issues
    }
}
