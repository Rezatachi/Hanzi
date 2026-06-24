import Foundation
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .today
    @Published var activeSheet: AppSheet?
    @Published var searchQuery: String = ""
    @Published var highlightedCardID: UUID?

    func open(cardID: UUID) {
        selectedTab = .today
        activeSheet = .card(cardID)
    }
}
