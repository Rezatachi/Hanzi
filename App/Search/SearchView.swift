import SwiftUI
import MandarinCore

struct SearchView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var router: AppRouter
    @State private var filter = SearchFilter()

    var body: some View {
        List {
            Section {
                Toggle("Saved only", isOn: $filter.savedOnly)
                Toggle("Due only", isOn: $filter.dueOnly)
                Toggle("Learned only", isOn: $filter.learnedOnly)
            }
            Section {
                if model.searchResults.isEmpty {
                    EmptyStateView(title: "No match yet", message: "Try pinyin without tone marks.", systemImage: "magnifyingglass")
                } else {
                    ForEach(model.searchResults) { result in
                        Button {
                            router.activeSheet = .card(result.entry.id)
                        } label: {
                            SearchResultRow(entry: result.entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Search")
        .searchable(text: $router.searchQuery, prompt: "Chinese, pinyin, or English")
        .onChange(of: router.searchQuery) { _, newValue in
            model.refreshSearch(query: newValue, filter: filter)
        }
        .onChange(of: filter) { _, newValue in
            model.refreshSearch(query: router.searchQuery, filter: newValue)
        }
        .task {
            if !router.searchQuery.isEmpty {
                model.refreshSearch(query: router.searchQuery, filter: filter)
            }
        }
    }
}
