import SwiftUI
import UserNotifications

@main
struct FocusKitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        Logger.shared.info("FocusKit app initialized")
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Logger.shared.error("Notification permission error: \(error.localizedDescription)")
            } else {
                Logger.shared.info("Notification permission granted: \(granted)")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Logger.shared.info("App delegate initialized")
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Logger.shared.debug("Notification will present: \(notification.request.content.title)")
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.shared.debug("Notification received: \(response.notification.request.content.title)")
        completionHandler()
    }
}
