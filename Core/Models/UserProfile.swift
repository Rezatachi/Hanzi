import Foundation

public enum CharacterMode: String, Codable, CaseIterable, Sendable, Identifiable {
    case simplified
    case traditional
    case both

    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .simplified: "Simplified"
        case .traditional: "Traditional"
        case .both: "Both"
        }
    }
}

public enum MandarinLevel: String, Codable, CaseIterable, Sendable, Identifiable {
    case completeBeginner
    case knowsPinyin
    case hsk1to2
    case hsk3to4
    case hsk5Plus
    case heritageRefresh

    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .completeBeginner: "Complete beginner"
        case .knowsPinyin: "Know pinyin"
        case .hsk1to2: "HSK 1-2"
        case .hsk3to4: "HSK 3-4"
        case .hsk5Plus: "HSK 5+"
        case .heritageRefresh: "Heritage refresh"
        }
    }
}

public enum LearningGoal: String, Codable, CaseIterable, Sendable, Identifiable {
    case travel
    case conversation
    case reading
    case hskPrep
    case business
    case cultureMedia
    case familyCommunity

    public var id: String { rawValue }
}

public enum LearningCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case basics
    case food
    case travel
    case family
    case work
    case school
    case emotions
    case time
    case numbers
    case shopping
    case transport
    case weather
    case health
    case technology
    case culture
    case idioms

    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if let category = Self(rawValue: rawValue) {
            self = category
            return
        }

        switch rawValue {
        case "conversation", "hello":
            self = .basics
        case "intro", "introduction", "introductions":
            self = .family
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported learning category: \(rawValue)"
            )
        }
    }
}

public enum PinyinVisibility: String, Codable, CaseIterable, Sendable, Identifiable {
    case alwaysVisible
    case hiddenUntilReveal
    case afterFirstAttempt

    public var id: String { rawValue }
}

public enum SubscriptionTier: String, Codable, CaseIterable, Sendable {
    case free
    case premium
    case lifetime
    case unknown
}

public struct UserProfile: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var displayName: String?
    public var createdAt: Date
    public var selectedCharacterMode: CharacterMode
    public var mandarinLevel: MandarinLevel
    public var dailyGoal: Int
    public var goals: [LearningGoal]
    public var interests: [LearningCategory]
    public var pinyinVisibility: PinyinVisibility
    public var ttsVoiceIdentifier: String?
    public var speechRate: Double
    public var reminderEnabled: Bool
    public var reminderTime: DateComponents?
    public var subscriptionTier: SubscriptionTier
    public var hasCompletedOnboarding: Bool
    public var analyticsOptOut: Bool

    public init(
        id: UUID = UUID(),
        displayName: String? = nil,
        createdAt: Date = .now,
        selectedCharacterMode: CharacterMode = .simplified,
        mandarinLevel: MandarinLevel = .completeBeginner,
        dailyGoal: Int = 3,
        goals: [LearningGoal] = [.conversation],
        interests: [LearningCategory] = [.basics, .travel],
        pinyinVisibility: PinyinVisibility = .alwaysVisible,
        ttsVoiceIdentifier: String? = nil,
        speechRate: Double = 0.45,
        reminderEnabled: Bool = false,
        reminderTime: DateComponents? = nil,
        subscriptionTier: SubscriptionTier = .free,
        hasCompletedOnboarding: Bool = false,
        analyticsOptOut: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.createdAt = createdAt
        self.selectedCharacterMode = selectedCharacterMode
        self.mandarinLevel = mandarinLevel
        self.dailyGoal = dailyGoal
        self.goals = goals
        self.interests = interests
        self.pinyinVisibility = pinyinVisibility
        self.ttsVoiceIdentifier = ttsVoiceIdentifier
        self.speechRate = speechRate
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.subscriptionTier = subscriptionTier
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.analyticsOptOut = analyticsOptOut
    }
}
