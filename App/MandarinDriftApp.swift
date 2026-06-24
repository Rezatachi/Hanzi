import SwiftUI
import MandarinCore

@main
struct MandarinDriftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var model = AppEnvironment.makeModel()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(model)
                .environmentObject(router)
                .task {
                    await model.bootstrap()
                }
        }
    }
}

enum AppEnvironment {
    @MainActor
    static func makeModel() -> AppModel {
        let store = LocalStore()
        let persistence = PersistenceController(
            profiles: LocalUserProfileRepository(store: store),
            entries: LocalHanziEntryRepository(store: store),
            reviews: LocalReviewStateRepository(store: store),
            logs: LocalReviewLogRepository(store: store),
            plans: LocalDailyPlanRepository(store: store),
            saved: LocalSavedEntryRepository(store: store),
            widget: LocalWidgetStateRepository(store: store),
            subscriptions: LocalSubscriptionRepository(store: store)
        )
        let contentService: ContentUpdateService
        if
            let urlString = Bundle.main.object(forInfoDictionaryKey: "ChineseDictionaryAPIURL") as? String,
            let url = URL(string: urlString),
            let formatString = Bundle.main.object(forInfoDictionaryKey: "ChineseDictionaryAPIFormat") as? String,
            let format = ChineseDictionaryRemoteFormat(rawValue: formatString)
        {
            let token = Bundle.main.object(forInfoDictionaryKey: "ChineseDictionaryAPIToken") as? String
            contentService = RemoteChineseDictionaryService(
                config: RemoteChineseDictionaryConfig(
                    url: url,
                    format: format,
                    bearerToken: token,
                    importLimit: 8000
                )
            )
        } else {
            contentService = MockContentUpdateService()
        }
        return AppModel(
            persistence: persistence,
            seedLoader: SeedImporter(bundle: .main),
            speech: MandarinSpeechService(),
            storeKit: MockStoreKitService(),
            contentUpdates: contentService
        )
    }
}
