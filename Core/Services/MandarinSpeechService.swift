import AVFoundation
import Foundation

public enum MandarinLocale: String, Sendable, CaseIterable, Identifiable {
    case zhCN = "zh-CN"
    case zhTW = "zh-TW"

    public var id: String { rawValue }
}

public struct VoiceOption: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let languageCode: String
}

public enum SpeechPlaybackState: Equatable, Sendable {
    case idle
    case speaking
    case paused
}

@MainActor
public protocol MandarinSpeechServicing: AnyObject, Sendable {
    var playbackState: SpeechPlaybackState { get }
    func speak(text: String, locale: MandarinLocale, voiceIdentifier: String?, rate: Double)
    func stop()
    func availableMandarinVoices() -> [VoiceOption]
}

@MainActor
public final class MandarinSpeechService: NSObject, MandarinSpeechServicing, @preconcurrency AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    public private(set) var playbackState: SpeechPlaybackState = .idle

    public override init() {
        super.init()
        synthesizer.delegate = self
    }

    public func speak(text: String, locale: MandarinLocale, voiceIdentifier: String?, rate: Double) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = Float(rate)
        utterance.voice = voiceIdentifier.flatMap(AVSpeechSynthesisVoice.init(identifier:)) ?? AVSpeechSynthesisVoice(language: locale.rawValue)
        playbackState = .speaking
        synthesizer.speak(utterance)
    }

    public func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        playbackState = .idle
    }

    public func availableMandarinVoices() -> [VoiceOption] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("zh") }
            .map { VoiceOption(id: $0.identifier, name: $0.name, languageCode: $0.language) }
            .sorted { $0.name < $1.name }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playbackState = .idle
    }
}
