import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        normalizeWindows()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        normalizeWindows()
    }

    private func normalizeWindows() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.backgroundColor = .systemBackground
                window.isOpaque = true
                window.clipsToBounds = false
                window.layer.cornerRadius = 0
                window.layer.masksToBounds = false
            }
        }
    }
}
