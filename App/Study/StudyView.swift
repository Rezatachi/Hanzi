import SwiftUI
import MandarinCore

struct StudyView: View {
    @EnvironmentObject private var model: AppModel
    @State private var activeMode: StudySessionMode = .review
    @State private var startSession = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Study")
                    .font(.title.bold())
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        chip("Review", mode: .review)
                        chip("New cards", mode: .newCards)
                        chip("Saved", mode: .saved)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due now")
                        .font(.headline)
                    Text(model.queue(for: activeMode).isEmpty ? "Clear for today. Want a tiny preview of tomorrow?" : "\(model.queue(for: activeMode).count) cards ready.")
                        .foregroundStyle(.secondary)
                }
                Button("Start session") { startSession = true }
                    .buttonStyle(.borderedProminent)
                    .tint(.driftAccentPrimary)
                SavedView(compact: true)
            }
            .padding()
        }
        .navigationDestination(isPresented: $startSession) {
            StudySessionView(mode: activeMode)
        }
    }

    private func chip(_ title: String, mode: StudySessionMode) -> some View {
        Button { activeMode = mode } label: {
            DeckChip(title: title, isSelected: activeMode == mode)
        }.buttonStyle(.plain)
    }
}
