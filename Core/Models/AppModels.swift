import Foundation

public enum ReminderPreset: String, CaseIterable, Codable, Sendable, Identifiable {
    case morning
    case lunch
    case evening
    case none

    public var id: String { rawValue }

    public var timeComponents: DateComponents? {
        switch self {
        case .morning: DateComponents(hour: 8, minute: 30)
        case .lunch: DateComponents(hour: 12, minute: 30)
        case .evening: DateComponents(hour: 19, minute: 30)
        case .none: nil
        }
    }
}

public enum StudyPromptStyle: String, CaseIterable, Codable, Sendable, Identifiable {
    case chineseOnly
    case chineseWithPinyin
    case englishPrompt
    case listeningPrompt

    public var id: String { rawValue }
}

public struct SearchFilter: Sendable, Equatable {
    public var savedOnly: Bool = false
    public var dueOnly: Bool = false
    public var learnedOnly: Bool = false
    public var hskLevel: String?
    public var category: LearningCategory?
    public var characterMode: CharacterMode?

    public init(savedOnly: Bool = false, dueOnly: Bool = false, learnedOnly: Bool = false, hskLevel: String? = nil, category: LearningCategory? = nil, characterMode: CharacterMode? = nil) {
        self.savedOnly = savedOnly
        self.dueOnly = dueOnly
        self.learnedOnly = learnedOnly
        self.hskLevel = hskLevel
        self.category = category
        self.characterMode = characterMode
    }
}

public struct SearchResult: Identifiable, Sendable, Equatable {
    public var id: UUID { entry.id }
    public let entry: HanziEntry
    public let score: Int

    public init(entry: HanziEntry, score: Int) {
        self.entry = entry
        self.score = score
    }
}

public struct ProgressSnapshot: Sendable, Equatable {
    public var streak: Int
    public var longestStreak: Int
    public var cardsLearned: Int
    public var cardsMastered: Int
    public var reviewsCompleted: Int
    public var averageAccuracy: Double
    public var dueToday: Int
    public var savedCount: Int
    public var weeklyActivity: [WeeklyActivityPoint]
    public var toneWeaknesses: [String]
    public var categoryProgress: [CategoryProgress]

    public init(streak: Int, longestStreak: Int, cardsLearned: Int, cardsMastered: Int, reviewsCompleted: Int, averageAccuracy: Double, dueToday: Int, savedCount: Int, weeklyActivity: [WeeklyActivityPoint], toneWeaknesses: [String], categoryProgress: [CategoryProgress]) {
        self.streak = streak
        self.longestStreak = longestStreak
        self.cardsLearned = cardsLearned
        self.cardsMastered = cardsMastered
        self.reviewsCompleted = reviewsCompleted
        self.averageAccuracy = averageAccuracy
        self.dueToday = dueToday
        self.savedCount = savedCount
        self.weeklyActivity = weeklyActivity
        self.toneWeaknesses = toneWeaknesses
        self.categoryProgress = categoryProgress
    }
}

public struct WeeklyActivityPoint: Identifiable, Sendable, Equatable {
    public var id: Date { date }
    public var date: Date
    public var reviews: Int

    public init(date: Date, reviews: Int) {
        self.date = date
        self.reviews = reviews
    }
}

public struct CategoryProgress: Identifiable, Sendable, Equatable {
    public var id: LearningCategory { category }
    public var category: LearningCategory
    public var learned: Int
    public var total: Int

    public init(category: LearningCategory, learned: Int, total: Int) {
        self.category = category
        self.learned = learned
        self.total = total
    }
}

public enum RemoteFeature: String, Sendable {
    case widgets
    case unlimitedReviews
    case wallpaper
    case advancedStats
    case allDecks
    case fullDictionary
}
