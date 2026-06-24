import Foundation

public protocol SearchServicing: Sendable {
    func search(
        query: String,
        entries: [HanziEntry],
        savedIds: Set<UUID>,
        dueIds: Set<UUID>,
        learnedIds: Set<UUID>,
        filter: SearchFilter
    ) -> [SearchResult]
}

public struct SearchService: SearchServicing {
    public init() {}

    public func search(
        query: String,
        entries: [HanziEntry],
        savedIds: Set<UUID>,
        dueIds: Set<UUID>,
        learnedIds: Set<UUID>,
        filter: SearchFilter = .init()
    ) -> [SearchResult] {
        let normalized = PinyinNormalizer.normalize(query)
        return entries.compactMap { entry in
            guard matchesFilter(entry: entry, savedIds: savedIds, dueIds: dueIds, learnedIds: learnedIds, filter: filter) else {
                return nil
            }
            let score = score(for: entry, query: query, normalized: normalized)
            return score >= 0 ? SearchResult(entry: entry, score: score) : nil
        }
        .sorted { lhs, rhs in
            if lhs.score == rhs.score { return lhs.entry.frequencyRank ?? 9999 < rhs.entry.frequencyRank ?? 9999 }
            return lhs.score > rhs.score
        }
    }

    private func matchesFilter(
        entry: HanziEntry,
        savedIds: Set<UUID>,
        dueIds: Set<UUID>,
        learnedIds: Set<UUID>,
        filter: SearchFilter
    ) -> Bool {
        if filter.savedOnly && !savedIds.contains(entry.id) { return false }
        if filter.dueOnly && !dueIds.contains(entry.id) { return false }
        if filter.learnedOnly && !learnedIds.contains(entry.id) { return false }
        if let hskLevel = filter.hskLevel, entry.hskLevel != hskLevel { return false }
        if let category = filter.category, !entry.categories.contains(category) { return false }
        if let characterMode = filter.characterMode, characterMode == .traditional, entry.traditional.isEmpty { return false }
        return true
    }

    private func score(for entry: HanziEntry, query: String, normalized: String) -> Int {
        if query.isEmpty { return 1 }
        if entry.simplified == query || entry.traditional == query { return 100 }
        if entry.simplified.hasPrefix(query) || entry.traditional.hasPrefix(query) { return 90 }
        if entry.pinyinSearch == normalized { return 80 }
        if entry.pinyinSearch.hasPrefix(normalized) { return 70 }
        if entry.pinyinNumeric.lowercased() == normalized { return 68 }
        if entry.definitions.joined(separator: " ").lowercased().contains(query.lowercased()) { return 60 }
        if entry.categories.map(\.rawValue).joined(separator: " ").contains(normalized) { return 50 }
        if entry.radical?.contains(query) == true { return 40 }
        return -1
    }
}
