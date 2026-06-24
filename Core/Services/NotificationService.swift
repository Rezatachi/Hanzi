import Foundation
import UserNotifications

public protocol NotificationServicing: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleDailyReminder(at components: DateComponents, body: String, deepLink: String) async throws
    func clearDailyReminders() async
}

public struct NotificationService: NotificationServicing {
    public init() {}

    public func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    public func scheduleDailyReminder(at components: DateComponents, body: String, deepLink: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Mandarin Drift"
        content.body = body
        content.sound = .default
        content.userInfo = ["deepLink": deepLink]
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-mandarin-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-mandarin-reminder"])
        try await UNUserNotificationCenter.current().add(request)
    }

    public func clearDailyReminders() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-mandarin-reminder"])
    }
}
