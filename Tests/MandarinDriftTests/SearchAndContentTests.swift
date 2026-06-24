import XCTest
import MandarinCore

final class SearchAndContentTests: XCTestCase {
    func testPinyinNormalizationRemovesDiacritics() {
        XCTAssertEqual(PinyinNormalizer.normalize("nǐ hǎo"), "ni hao")
        XCTAssertEqual(PinyinNormalizer.normalize("lüe"), "lve")
    }

    func testSearchFindsPinyinWithoutTones() {
        let service = SearchService()
        let entry = Fixtures.entry
        let results = service.search(query: "ni", entries: [entry], savedIds: [], dueIds: [], learnedIds: [], filter: .init())
        XCTAssertEqual(results.first?.entry.id, entry.id)
    }

    func testContentValidatorRejectsEmptyFields() {
        let bad = HanziEntry(
            id: UUID(), simplified: "", traditional: "", pinyin: "", pinyinNumeric: "", pinyinSearch: "", definitions: [], partOfSpeech: nil, hskLevel: nil, frequencyRank: nil, radical: nil, radicalMeaning: nil, strokeCount: nil, components: [], categories: [], exampleChineseSimplified: "", exampleChineseTraditional: nil, examplePinyin: "", exampleEnglish: "", usageNote: nil, memoryHook: nil, toneTip: nil, commonMistake: nil, relatedEntryIds: [], isPremium: false, createdAt: .now, updatedAt: .now
        )
        XCTAssertFalse(ContentValidator.validate(entries: [bad]).isEmpty)
    }

    func testSeedImportIsIdempotent() async throws {
        let repo = InMemoryHanziEntryRepository(entries: [Fixtures.entry])
        try await repo.importSeedIfNeeded([Fixtures.entry])
        let entries = try await repo.allEntries()
        XCTAssertEqual(entries.count, 1)
    }
}
