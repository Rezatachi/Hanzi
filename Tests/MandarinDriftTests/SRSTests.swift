import XCTest
import MandarinCore
@testable import MandarinDrift

final class SRSTests: XCTestCase {
    func testAgainLowersEaseAndSchedulesSoon() {
        let service = SRSService()
        let state = ReviewState(entryId: UUID(), userId: UUID(), state: .review, dueAt: .now, intervalDays: 4, easeFactor: 2.5, repetitions: 3, lapses: 0)
        let result = service.grade(state: state, grade: .again, now: .now)
        XCTAssertEqual(result.newState.state, .learning)
        XCTAssertEqual(result.newState.easeFactor, 2.3, accuracy: 0.001)
        XCTAssertLessThan(result.newState.intervalDays, 0.03)
    }

    func testGoodOnNewCardSchedulesTomorrow() {
        let service = SRSService()
        let state = ReviewState(entryId: UUID(), userId: UUID())
        let result = service.grade(state: state, grade: .good, now: .now)
        XCTAssertEqual(result.newState.state, .review)
        XCTAssertEqual(result.newState.intervalDays, 1)
    }

    func testEasyIncreasesEase() {
        let service = SRSService()
        let state = ReviewState(entryId: UUID(), userId: UUID(), state: .review, dueAt: .now, intervalDays: 3, easeFactor: 2.5, repetitions: 2, lapses: 0)
        let result = service.grade(state: state, grade: .easy, now: .now)
        XCTAssertGreaterThan(result.newState.easeFactor, 2.5)
        XCTAssertGreaterThan(result.newState.intervalDays, 3)
    }

    func testRemovedCardsNeverAppearInQueue() {
        let service = SRSService()
        let userID = UUID()
        let entry = Fixtures.entry
        let states = [ReviewState(entryId: entry.id, userId: userID, state: .removed, dueAt: .distantPast, intervalDays: 1, easeFactor: 2.5, repetitions: 1, lapses: 0)]
        let queue = service.dueQueue(entries: [entry], states: states, userId: userID, dailyGoal: 3, now: .now)
        XCTAssertTrue(queue.isEmpty)
    }

    func testDueQueueRespectsDailyLimitForNewCards() {
        let service = SRSService()
        let userID = UUID()
        let entries = (0..<5).map { index in Fixtures.entry(simplified: "词\(index)", rank: index + 1) }
        let queue = service.dueQueue(entries: entries, states: [], userId: userID, dailyGoal: 2, now: .now)
        XCTAssertEqual(queue.count, 2)
    }
}

enum Fixtures {
    static let entry = HanziEntry(
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
        categories: [.basics],
        exampleChineseSimplified: "你好。",
        exampleChineseTraditional: "你好。",
        examplePinyin: "Nǐ hǎo.",
        exampleEnglish: "Hello.",
        usageNote: "Use in greetings.",
        memoryHook: "A person on the left.",
        toneTip: "Third tone dips.",
        commonMistake: "Do not flatten it.",
        relatedEntryIds: [],
        isPremium: false,
        createdAt: .now,
        updatedAt: .now
    )

    static func entry(simplified: String, rank: Int) -> HanziEntry {
        HanziEntry(
            id: UUID(),
            simplified: simplified,
            traditional: simplified,
            pinyin: "cí",
            pinyinNumeric: "ci2",
            pinyinSearch: "ci",
            definitions: ["word"],
            partOfSpeech: "word",
            hskLevel: "HSK 1",
            frequencyRank: rank,
            radical: nil,
            radicalMeaning: nil,
            strokeCount: nil,
            components: [],
            categories: [.basics],
            exampleChineseSimplified: "\(simplified) 很常见。",
            exampleChineseTraditional: "\(simplified) 很常見。",
            examplePinyin: "Hěn chángjiàn.",
            exampleEnglish: "Common word.",
            usageNote: nil,
            memoryHook: nil,
            toneTip: nil,
            commonMistake: nil,
            relatedEntryIds: [],
            isPremium: false,
            createdAt: .now,
            updatedAt: .now
        )
    }
}
