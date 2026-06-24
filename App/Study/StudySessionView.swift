import SwiftUI
import MandarinCore

struct StudySessionView: View {
    @EnvironmentObject private var model: AppModel
    let mode: StudySessionMode
    @State private var queue: [ReviewQueueItem] = []
    @State private var index = 0
    @State private var isRevealed = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            if queue.isEmpty {
                EmptyStateView(title: "Done for today", message: "Clear for today. Want a tiny preview of tomorrow?", systemImage: "checkmark.circle")
            } else if let current = currentItem {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("Card \(index + 1) of \(queue.count)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        AudioButton(label: "Listen", systemImage: "speaker.wave.2") {
                            let locale: MandarinLocale = model.profile.selectedCharacterMode == .traditional ? .zhTW : .zhCN
                            model.speech.speak(text: current.entry.simplified, locale: locale, voiceIdentifier: model.profile.ttsVoiceIdentifier, rate: model.profile.speechRate)
                        }
                    }
                    MandarinCardView(entry: current.entry, characterMode: model.profile.selectedCharacterMode)
                    if isRevealed {
                        gradingRow(for: current.entry)
                    } else {
                        Button("Reveal") { isRevealed = true }
                            .buttonStyle(.borderedProminent)
                            .tint(.driftAccentPrimary)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Session")
        .task {
            queue = model.queue(for: mode)
            await model.analytics.track(event: .studySessionStarted, metadata: ["mode": mode.rawValue])
        }
    }

    private var currentItem: ReviewQueueItem? {
        guard queue.indices.contains(index) else { return nil }
        return queue[index]
    }

    private func gradingRow(for entry: HanziEntry) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                SRSGradeButton(title: "Again", tint: .driftDestructive) { submit(.again, entry: entry) }
                SRSGradeButton(title: "Hard", tint: .driftWarning) { submit(.hard, entry: entry) }
            }
            HStack(spacing: 10) {
                SRSGradeButton(title: "Good", tint: .driftAccentSecondary) { submit(.good, entry: entry) }
                SRSGradeButton(title: "Easy", tint: .driftSuccess) { submit(.easy, entry: entry) }
            }
        }
    }

    private func submit(_ grade: ReviewGrade, entry: HanziEntry) {
        Task {
            await model.grade(entry: entry, grade: grade)
            if index + 1 < queue.count {
                index += 1
                isRevealed = false
            } else {
                await model.analytics.track(event: .studySessionCompleted, metadata: ["mode": mode.rawValue])
                dismiss()
            }
        }
    }
}
