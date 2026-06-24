import Foundation

enum AppTab: Hashable {
    case today
    case study
    case search
    case progress
    case profile
}

enum AppSheet: Identifiable {
    case paywall
    case wallpaper
    case widgetSettings
    case card(UUID)

    var id: String {
        switch self {
        case .paywall: "paywall"
        case .wallpaper: "wallpaper"
        case .widgetSettings: "widgetSettings"
        case .card(let id): "card-\(id.uuidString)"
        }
    }
}
