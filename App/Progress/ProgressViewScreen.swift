import SwiftUI
import Charts

struct ProgressViewScreen: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Progress").font(.title.bold())
                HStack(spacing: 12) {
                    metricCard("Streak", value: "\(model.progress.streak)")
                    metricCard("Learned", value: "\(model.progress.cardsLearned)")
                }
                HStack(spacing: 12) {
                    metricCard("Mastered", value: "\(model.progress.cardsMastered)")
                    metricCard("Accuracy", value: "\(Int(model.progress.averageAccuracy * 100))%")
                }
                Chart(model.progress.weeklyActivity) {
                    BarMark(x: .value("Day", $0.date, unit: .day), y: .value("Reviews", $0.reviews))
                        .foregroundStyle(Color.driftAccentPrimary)
                }
                .frame(height: 200)
                .padding()
                .background(Color.driftCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tone focus").font(.headline)
                    ForEach(model.progress.toneWeaknesses, id: \.self) { tip in
                        Text("• \(tip)").foregroundStyle(.secondary)
                    }
                    if model.progress.toneWeaknesses.isEmpty {
                        Text("No strong weak-tone cluster yet. Keep listening first.")
                            .foregroundStyle(.secondary)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category progress").font(.headline)
                    ForEach(model.progress.categoryProgress) { category in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.category.title)
                            ProgressView(value: category.total == 0 ? 0 : Double(category.learned) / Double(category.total))
                                .tint(.driftAccentSecondary)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func metricCard(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).foregroundStyle(.secondary)
            Text(value).font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.driftCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
