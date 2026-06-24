import SwiftUI
import MandarinCore

struct CardDetailView: View {
    @EnvironmentObject private var model: AppModel
    let entry: HanziEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MandarinCardView(entry: entry, characterMode: model.profile.selectedCharacterMode)
                detailSection("Character anatomy") {
                    flowPills([
                        entry.radical.map { "Radical \($0)" },
                        entry.radicalMeaning.map { "Meaning \($0)" },
                        entry.strokeCount.map { "\($0) strokes" }
                    ].compactMap { $0 } + entry.components.map { "Part \($0)" })
                }
                detailSection("Micro-context") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.usageNote ?? "Use it in short, natural contexts.")
                        Text(entry.memoryHook ?? "Tie the sound to one familiar scene.")
                        Text(entry.toneTip ?? "Listen for the tone before recall.")
                        Text(entry.commonMistake ?? "Keep pronunciation relaxed and clear.")
                    }
                    .foregroundStyle(.secondary)
                }
                detailSection("Example") {
                    ExampleSentenceView(
                        chinese: model.profile.selectedCharacterMode == .traditional ? (entry.exampleChineseTraditional ?? entry.exampleChineseSimplified) : entry.exampleChineseSimplified,
                        pinyin: entry.examplePinyin,
                        english: entry.exampleEnglish
                    )
                }
                HStack {
                    AudioButton(label: "Word", systemImage: "speaker.wave.2") {
                        model.speech.speak(text: entry.simplified, locale: model.profile.selectedCharacterMode == .traditional ? .zhTW : .zhCN, voiceIdentifier: model.profile.ttsVoiceIdentifier, rate: model.profile.speechRate)
                    }
                    AudioButton(label: "Sentence", systemImage: "text.bubble") {
                        model.speech.speak(text: entry.exampleChineseSimplified, locale: model.profile.selectedCharacterMode == .traditional ? .zhTW : .zhCN, voiceIdentifier: model.profile.ttsVoiceIdentifier, rate: model.profile.speechRate)
                    }
                }
                HStack {
                    Button(model.isSaved(entry.id) ? "Saved" : "Save") {
                        Task { await model.toggleSave(entry: entry) }
                    }.buttonStyle(.borderedProminent).tint(.driftAccentPrimary)
                    Button("Remove from review", role: .destructive) {
                        Task { await model.removeFromReview(entry: entry) }
                    }.buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle(entry.simplified)
    }

    private func detailSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            content()
        }
    }

    private func flowPills(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.chunked(into: 3), id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { item in
                        RadicalInfoPill(text: item)
                    }
                }
            }
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}
