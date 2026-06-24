import XCTest
import MandarinCore

final class WidgetStateTests: XCTestCase {
    func testWidgetStateServiceCreatesDeepLink() {
        let entry = HanziEntry(
            id: UUID(),
            simplified: "你",
            traditional: "你",
            pinyin: "nǐ",
            pinyinNumeric: "ni3",
            pinyinSearch: "ni",
            definitions: ["you"],
            partOfSpeech: "word",
            hskLevel: "HSK 1",
            frequencyRank: 1,
            radical: "亻",
            radicalMeaning: "person",
            strokeCount: 7,
            components: ["亻", "尔"],
            categories: [LearningCategory.basics],
            exampleChineseSimplified: "你好。",
            exampleChineseTraditional: "你好。",
            examplePinyin: "Nǐ hǎo.",
            exampleEnglish: "Hello.",
            usageNote: "Use in greetings.",
            memoryHook: nil,
            toneTip: nil,
            commonMistake: nil,
            relatedEntryIds: [],
            isPremium: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        let plan = DailyPlan(id: UUID(), userId: UUID(), date: Date(), featuredEntryId: entry.id, sceneTitle: "Cafe", sceneDescription: "A scene.", relatedEntryIds: [], completedNewCards: 0, completedReviews: 0, goalCount: 3)
        let service = WidgetStateService(store: InMemoryWidgetStateStore())
        let state = service.makeState(plan: plan, entry: entry, progressText: "3 due", mode: .todayCard)
        XCTAssertTrue(state.deepLinkURL.contains("mandarinapp://card"))
    }
}

private struct InMemoryWidgetStateStore: WidgetStateWriting {
    func write(_ state: WidgetState) throws {}
    func read() throws -> WidgetState? { nil }
}
