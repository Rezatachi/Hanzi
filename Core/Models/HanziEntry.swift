import Foundation

public struct HanziEntry: Identifiable, Codable, Sendable, Hashable {
    public var id: UUID
    public var simplified: String
    public var traditional: String
    public var pinyin: String
    public var pinyinNumeric: String
    public var pinyinSearch: String
    public var definitions: [String]
    public var partOfSpeech: String?
    public var hskLevel: String?
    public var frequencyRank: Int?
    public var radical: String?
    public var radicalMeaning: String?
    public var strokeCount: Int?
    public var components: [String]
    public var categories: [LearningCategory]
    public var exampleChineseSimplified: String
    public var exampleChineseTraditional: String?
    public var examplePinyin: String
    public var exampleEnglish: String
    public var usageNote: String?
    public var memoryHook: String?
    public var toneTip: String?
    public var commonMistake: String?
    public var relatedEntryIds: [UUID]
    public var isPremium: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID,
        simplified: String,
        traditional: String,
        pinyin: String,
        pinyinNumeric: String,
        pinyinSearch: String,
        definitions: [String],
        partOfSpeech: String?,
        hskLevel: String?,
        frequencyRank: Int?,
        radical: String?,
        radicalMeaning: String?,
        strokeCount: Int?,
        components: [String],
        categories: [LearningCategory],
        exampleChineseSimplified: String,
        exampleChineseTraditional: String?,
        examplePinyin: String,
        exampleEnglish: String,
        usageNote: String?,
        memoryHook: String?,
        toneTip: String?,
        commonMistake: String?,
        relatedEntryIds: [UUID],
        isPremium: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.simplified = simplified
        self.traditional = traditional
        self.pinyin = pinyin
        self.pinyinNumeric = pinyinNumeric
        self.pinyinSearch = pinyinSearch
        self.definitions = definitions
        self.partOfSpeech = partOfSpeech
        self.hskLevel = hskLevel
        self.frequencyRank = frequencyRank
        self.radical = radical
        self.radicalMeaning = radicalMeaning
        self.strokeCount = strokeCount
        self.components = components
        self.categories = categories
        self.exampleChineseSimplified = exampleChineseSimplified
        self.exampleChineseTraditional = exampleChineseTraditional
        self.examplePinyin = examplePinyin
        self.exampleEnglish = exampleEnglish
        self.usageNote = usageNote
        self.memoryHook = memoryHook
        self.toneTip = toneTip
        self.commonMistake = commonMistake
        self.relatedEntryIds = relatedEntryIds
        self.isPremium = isPremium
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var shortDefinition: String { definitions.first ?? "" }
}
