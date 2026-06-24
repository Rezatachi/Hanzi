import CryptoKit
import Foundation

public enum CEDICTParserError: Error {
    case invalidEncoding
}

public struct CEDICTParser: Sendable {
    public init() {}

    public func parse(data: Data, limit: Int? = nil) throws -> [HanziEntry] {
        guard let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .utf8) else {
            throw CEDICTParserError.invalidEncoding
        }
        return parse(text: text, limit: limit)
    }

    public func parse(text: String, limit: Int? = nil) -> [HanziEntry] {
        var entries: [HanziEntry] = []

        for line in text.split(separator: "\n") {
            if let limit, entries.count >= limit { break }
            let rawLine = String(line)
            guard !rawLine.hasPrefix("#"), !rawLine.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            guard let entry = parseLine(rawLine) else { continue }
            entries.append(entry)
        }

        return entries
    }

    private func parseLine(_ line: String) -> HanziEntry? {
        guard
            let openBracket = line.firstIndex(of: "["),
            let closeBracket = line.firstIndex(of: "]"),
            let firstSlash = line.firstIndex(of: "/"),
            openBracket < closeBracket,
            closeBracket < firstSlash
        else {
            return nil
        }

        let head = line[..<openBracket].trimmingCharacters(in: .whitespaces)
        let pinyinNumeric = line[line.index(after: openBracket)..<closeBracket].trimmingCharacters(in: .whitespaces)
        let defsRaw = line[firstSlash...]
        let headParts = head.split(separator: " ", omittingEmptySubsequences: true)
        guard headParts.count >= 2 else { return nil }

        let traditional = String(headParts[0])
        let simplified = String(headParts[1])
        let definitions = defsRaw
            .split(separator: "/")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !definitions.isEmpty else { return nil }

        let displayPinyin = NumericPinyinConverter.toToneMarks(pinyinNumeric)
        let entryID = StableEntryID.make(for: traditional, simplified: simplified, pinyinNumeric: pinyinNumeric)

        return HanziEntry(
            id: entryID,
            simplified: simplified,
            traditional: traditional,
            pinyin: displayPinyin,
            pinyinNumeric: pinyinNumeric,
            pinyinSearch: PinyinNormalizer.normalize(pinyinNumeric),
            definitions: definitions,
            partOfSpeech: "dictionary",
            hskLevel: nil,
            frequencyRank: nil,
            radical: nil,
            radicalMeaning: nil,
            strokeCount: nil,
            components: Array(simplified).map(String.init),
            categories: [LearningCategory.basics],
            exampleChineseSimplified: simplified,
            exampleChineseTraditional: traditional,
            examplePinyin: displayPinyin,
            exampleEnglish: definitions.first ?? "Imported dictionary entry",
            usageNote: "Imported from a large dictionary source.",
            memoryHook: nil,
            toneTip: nil,
            commonMistake: nil,
            relatedEntryIds: [],
            isPremium: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

enum NumericPinyinConverter {
    private static let toneMap: [Character: [Character]] = [
        "a": ["a", "ā", "á", "ǎ", "à"],
        "e": ["e", "ē", "é", "ě", "è"],
        "i": ["i", "ī", "í", "ǐ", "ì"],
        "o": ["o", "ō", "ó", "ǒ", "ò"],
        "u": ["u", "ū", "ú", "ǔ", "ù"],
        "v": ["ü", "ǖ", "ǘ", "ǚ", "ǜ"]
    ]

    static func toToneMarks(_ numeric: String) -> String {
        numeric
            .split(separator: " ")
            .map { syllable in
                guard let toneDigit = syllable.last, let tone = Int(String(toneDigit)), (0...5).contains(tone) else {
                    return String(syllable).replacingOccurrences(of: "u:", with: "ü")
                }

                let base = String(syllable.dropLast()).replacingOccurrences(of: "u:", with: "v")
                return applyTone(base: base, tone: tone)
            }
            .joined(separator: " ")
    }

    private static func applyTone(base: String, tone: Int) -> String {
        guard tone > 0 && tone < 5 else { return base.replacingOccurrences(of: "v", with: "ü") }
        var chars = Array(base)
        let priority: [Character] = ["a", "e", "o"]
        let targetIndex =
            chars.firstIndex(where: { priority.contains($0) }) ??
            (chars.count >= 2 && chars[chars.count - 2] == "i" && chars.last == "u" ? chars.count - 2 : nil) ??
            (chars.count >= 2 && chars[chars.count - 2] == "u" && chars.last == "i" ? chars.count - 1 : nil) ??
            chars.firstIndex(where: { toneMap[$0] != nil })

        guard let index = targetIndex, let replacement = toneMap[chars[index]]?[tone] else {
            return base.replacingOccurrences(of: "v", with: "ü")
        }
        chars[index] = replacement
        return String(chars).replacingOccurrences(of: "v", with: "ü")
    }
}

enum StableEntryID {
    static func make(for traditional: String, simplified: String, pinyinNumeric: String) -> UUID {
        let value = "\(traditional)|\(simplified)|\(pinyinNumeric)"
        let digest = Insecure.MD5.hash(data: Data(value.utf8))
        let bytes = Array(digest)
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
