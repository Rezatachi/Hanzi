import SwiftUI
import MandarinCore

struct AppRootView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            Color.driftBackgroundPrimary.ignoresSafeArea()
            if model.isLoading {
                ProgressView("Loading Mandarin Drift")
                    .tint(.driftAccentPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !model.profile.hasCompletedOnboarding {
                OnboardingFlowView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                MainTabView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(item: $router.activeSheet) { sheet in
            switch sheet {
            case .paywall:
                PaywallView()
            case .wallpaper:
                WallpaperGeneratorView()
            case .widgetSettings:
                WidgetSettingsView()
            case .card(let id):
                if let entry = model.entries.first(where: { $0.id == id }) {
                    NavigationStack { CardDetailView(entry: entry) }
                }
            }
        }
        .onOpenURL { url in
            guard let destination = DeepLinkRouter.route(url: url) else { return }
            switch destination {
            case .today:
                router.selectedTab = .today
            case .review, .study:
                router.selectedTab = .study
            case .search(let query):
                router.selectedTab = .search
                router.searchQuery = query ?? ""
            case .card(let id):
                router.open(cardID: id)
            case .saved:
                router.selectedTab = .study
            case .progress:
                router.selectedTab = .progress
            case .widgetSettings:
                router.activeSheet = .widgetSettings
            case .wallpaper:
                router.activeSheet = .wallpaper
            case .paywall:
                router.activeSheet = .paywall
            }
        }
        .alert("Notice", isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}

private struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack { TodayView() }
                .tabItem { Label("Today", systemImage: "sun.max") }
                .tag(AppTab.today)
            NavigationStack { StudyView() }
                .tabItem { Label("Study", systemImage: "rectangle.stack") }
                .tag(AppTab.study)
            NavigationStack { SearchView() }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppTab.search)
            NavigationStack { ProgressViewScreen() }
                .tabItem { Label("Progress", systemImage: "chart.bar") }
                .tag(AppTab.progress)
            NavigationStack { ProfileSettingsView() }
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(AppTab.profile)
        }
        .tint(.driftAccentPrimary)
    }
}
