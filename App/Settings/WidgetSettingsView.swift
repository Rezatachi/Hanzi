import SwiftUI
import MandarinCore

struct WidgetSettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Widget mode") {
                    ForEach(WidgetMode.allCases) { mode in
                        Button {
                            model.widgetMode = mode
                            guard let fallbackEntry = model.featuredEntry() ?? model.entries.first else { return }
                            try? model.widgetService.write(model.widgetService.makeState(
                                plan: model.currentPlan ?? DailyPlan(id: UUID(), userId: model.profile.id, date: .now, featuredEntryId: fallbackEntry.id, sceneTitle: "Today", sceneDescription: "", relatedEntryIds: [], completedNewCards: 0, completedReviews: 0, goalCount: model.profile.dailyGoal),
                                entry: fallbackEntry,
                                progressText: "\(model.progress.dueToday) due",
                                mode: mode
                            ))
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(mode.rawValue)
                                    Text(description(for: mode)).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if model.widgetMode == mode { Image(systemName: "checkmark") }
                            }
                        }
                    }
                }
                Section("Preview") {
                    WidgetPreviewCard(title: model.featuredEntry()?.simplified ?? "今天", subtitle: model.featuredEntry()?.shortDefinition ?? "today")
                }
                Section("Setup") {
                    Text("Long press the Home Screen, tap Edit, then Add Widget and choose Mandarin Drift.")
                }
            }
            .navigationTitle("Widgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func description(for mode: WidgetMode) -> String {
        switch mode {
        case .todayCard: "Today’s featured word."
        case .dueReview: "A due count and quick prompt."
        case .savedRandom: "A saved word on rotation."
        case .toneChallenge: "A short tone-first recall cue."
        }
    }
}
