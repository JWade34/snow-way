import UIKit
import Capacitor
import CoreSpotlight
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Buttons on a long-pressed notification. The ids reach pwa.js as actionId; "stay" opens the lodging page.
        let forecast = UNNotificationAction(identifier: "forecast", title: "See forecast", options: [.foreground], icon: .init(systemImageName: "cloud.snow"))
        let stay = UNNotificationAction(identifier: "stay", title: "Places to stay", options: [.foreground], icon: .init(systemImageName: "bed.double"))
        let deal = UNNotificationAction(identifier: "deal", title: "See the deal", options: [.foreground], icon: .init(systemImageName: "tag"))
        UNUserNotificationCenter.current().setNotificationCategories([
            UNNotificationCategory(identifier: "POWDER_ALERT", actions: [forecast, stay], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "GEAR_DEAL", actions: [deal], intentIdentifiers: [], options: [])
        ])
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: "snowway.sessions") + 1, forKey: "snowway.sessions")
        if #available(iOS 16.0, *) { SnowWayShortcuts.updateAppShortcutParameters() }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Hands the APNs device token to Capacitor's PushNotifications plugin, which passes it to snowway.app.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: .capacitorDidRegisterForRemoteNotifications, object: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: .capacitorDidFailToRegisterForRemoteNotifications, object: error)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Widget taps open snowway://resorts/vail (or snowway:///) in the app.
        if url.scheme == "snowway" {
            let path = "/" + [url.host, url.path].compactMap { $0 }.joined().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            SnowWayViewController.open(path: path)
            NotificationCenter.default.post(name: .snowWayOpenPath, object: path)
            return true
        }
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // A resort tapped in Spotlight or Siri Suggestions.
        if userActivity.activityType == SnowWayPlugin.resortActivity, let path = userActivity.userInfo?["path"] as? String {
            SnowWayViewController.open(path: path)
            return true
        }
        if userActivity.activityType == CSSearchableItemActionType,
           let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String, id.hasPrefix("resort-") {
            SnowWayViewController.open(path: "/resorts/" + id.dropFirst("resort-".count))
            return true
        }
        // Called when the app was launched with an activity, including Universal Links.
        // Feel free to add additional processing here, but if you want the App API to support
        // tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

}
