import Foundation

enum DeepLinkDestination: Equatable {
    case today
    case review
    case study
    case search(String?)
    case card(UUID)
    case saved
    case progress
    case widgetSettings
    case wallpaper
    case paywall
}

enum DeepLinkRouter {
    static func route(url: URL) -> DeepLinkDestination? {
        guard url.scheme == "mandarinapp" else { return nil }
        let host = url.host ?? ""
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "today":
            return .today
        case "review":
            return .review
        case "study":
            return .study
        case "search":
            let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "q" })?
                .value
            return .search(query)
        case "card":
            guard let first = pathComponents.first, let id = UUID(uuidString: first) else { return nil }
            return .card(id)
        case "saved":
            return .saved
        case "progress":
            return .progress
        case "widget":
            return pathComponents.first == "settings" ? .widgetSettings : nil
        case "wallpaper":
            return .wallpaper
        case "paywall":
            return .paywall
        default:
            return nil
        }
    }
}
