import SwiftUI
import MandarinCore

struct SavedView: View {
    @EnvironmentObject private var model: AppModel
    var compact: Bool = false

    var body: some View {
        let savedCards = model.entries.filter { entry in model.savedEntries.contains(where: { $0.entryId == entry.id }) }
        Group {
            if savedCards.isEmpty {
                EmptyStateView(title: "No saved cards", message: "Save words you want to keep close.", systemImage: "bookmark")
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    if !compact { Text("Saved").font(.title2.bold()) }
                    ForEach(savedCards.prefix(compact ? 5 : savedCards.count), id: \.id) { entry in
                        NavigationLink {
                            CardDetailView(entry: entry)
                        } label: {
                            SearchResultRow(entry: entry)
                        }
                    }
                }
            }
        }
    }
}
