import Foundation

public enum AnalyticsEvent: String, Sendable {
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case dailyCardViewed = "daily_card_viewed"
    case cardRevealed = "card_revealed"
    case cardReviewed = "card_reviewed"
    case studySessionStarted = "study_session_started"
    case studySessionCompleted = "study_session_completed"
    case searchPerformed = "search_performed"
    case cardSaved = "card_saved"
    case widgetSettingsChanged = "widget_settings_changed"
    case wallpaperExported = "wallpaper_exported"
    case paywallViewed = "paywall_viewed"
    case purchaseStarted = "purchase_started"
    case purchaseCompleted = "purchase_completed"
    case purchaseFailed = "purchase_failed"
    case restoreStarted = "restore_started"
    case restoreCompleted = "restore_completed"
    case notificationPermissionRequested = "notification_permission_requested"
    case notificationOpened = "notification_opened"
}

public protocol AnalyticsService: Sendable {
    func track(event: AnalyticsEvent, metadata: [String: String]) async
    func setUserProperty(key: String, value: String?) async
    func optOut() async
}

public actor LocalAnalyticsService: AnalyticsService {
    private var isOptedOut = false

    public init() {}

    public func track(event: AnalyticsEvent, metadata: [String: String] = [:]) async {
        guard !isOptedOut else { return }
        #if DEBUG
        print("Analytics:", event.rawValue, metadata)
        #endif
    }

    public func setUserProperty(key: String, value: String?) async {
        guard !isOptedOut else { return }
        #if DEBUG
        print("Analytics user property:", key, value ?? "nil")
        #endif
    }

    public func optOut() async {
        isOptedOut = true
    }
}
