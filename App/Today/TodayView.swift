import SwiftUI
import MandarinCore

struct TodayView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if let entry = model.featuredEntry() {
                    Button {
                        router.activeSheet = .card(entry.id)
                    } label: {
                        MandarinCardView(entry: entry, characterMode: model.profile.selectedCharacterMode)
                    }
                    .buttonStyle(.plain)
                } else {
                    EmptyStateView(
                        title: "No daily card yet",
                        message: "Import more dictionary content or check the local seed data.",
                        systemImage: "book.closed"
                    )
                }
                actions
                scene
                widgetPrompt
            }
            .padding()
        }
        .navigationTitle("Today")
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("One character. One useful sentence.")
                    .font(.title.bold())
                Text("Tiny reviews, real progress.")
                    .foregroundStyle(.secondary)
                StreakBadge(streak: model.progress.streak)
            }
            Spacer()
            ProgressRing(progress: min(Double((model.currentPlan?.completedReviews ?? 0) + (model.currentPlan?.completedNewCards ?? 0)) / Double(max(model.profile.dailyGoal, 1)), 1))
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                quickAction(title: "Review", subtitle: "\(model.progress.dueToday) due", icon: "arrow.clockwise") {
                    router.selectedTab = .study
                }
                quickAction(title: "Search", subtitle: "Dictionary", icon: "magnifyingglass") {
                    router.selectedTab = .search
                }
            }
            HStack(spacing: 12) {
                quickAction(title: "Saved", subtitle: "\(model.progress.savedCount) kept", icon: "bookmark") {
                    router.selectedTab = .study
                }
                quickAction(title: "Wallpaper", subtitle: "Study mode", icon: "photo") {
                    router.activeSheet = .wallpaper
                }
            }
        }
    }

    private var scene: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(model.currentPlan?.sceneTitle ?? "Daily scene")
                .font(.headline)
            Text(model.currentPlan?.sceneDescription ?? "")
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(model.relatedEntries(), id: \.id) { entry in
                        WidgetPreviewCard(title: entry.simplified, subtitle: "\(entry.pinyin) · \(entry.shortDefinition)")
                            .frame(width: 180)
                    }
                }
            }
        }
    }

    private var widgetPrompt: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Unlock, glance, recall.")
                .font(.headline)
            Text("Add a widget when you want the card to stay visible between sessions.")
                .foregroundStyle(.secondary)
            Button("Widget setup") { router.activeSheet = .widgetSettings }
                .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.driftCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func quickAction(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon).font(.headline)
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.driftCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}
