import Capacitor
import CoreSpotlight
import StoreKit
import UIKit
import UserNotifications
import WidgetKit

// Native features the website asks for through window.snowwayApp.native(...) in pwa.js.
@objc(SnowWayPlugin)
public class SnowWayPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SnowWayPlugin"
    public let jsName = "SnowWay"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "clearBadge", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestReview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "viewedResort", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "storefront", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setPass", returnType: CAPPluginReturnPromise)
    ]

    static let resortActivity = "app.snowway.resort"
    private var activity: NSUserActivity?

    // The App Store country this copy came from ("USA"). Tip links show only on the US storefront.
    @objc func storefront(_ call: CAPPluginCall) {
        Task {
            let code = await Storefront.current?.countryCode
            call.resolve(["countryCode": code ?? ""])
        }
    }

    // The visitor's ski pass (epic, ikon, indy, mountain_collective, none). Siri's answers filter to it.
    @objc func setPass(_ call: CAPPluginCall) {
        UserDefaults.standard.set(call.getString("pass"), forKey: SnowWayAPI.passKey)
        call.resolve()
    }

    @objc func clearBadge(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if #available(iOS 16.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(0)
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        call.resolve()
    }

    // Asks for an App Store rating at a happy moment. Apple decides whether to show it (at most 3 times a year)
    // and never in TestFlight builds. Waits for the 3rd app session, so brand new users aren't asked.
    @objc func requestReview(_ call: CAPPluginCall) {
        let defaults = UserDefaults.standard
        let sessions = defaults.integer(forKey: "snowway.sessions")
        let lastAsked = defaults.double(forKey: "snowway.reviewAskedAt")
        guard sessions >= 3, Date().timeIntervalSince1970 - lastAsked > 60 * 60 * 24 * 120 else { return call.resolve() }
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                defaults.set(Date().timeIntervalSince1970, forKey: "snowway.reviewAskedAt")
                SKStoreReviewController.requestReview(in: scene)
            }
            call.resolve()
        }
    }

    // A resort page was opened. Tells iOS, so Spotlight search finds the resort and Siri Suggestions can offer it.
    // Refreshes the widgets too, so they pick up new forecasts.
    @objc func viewedResort(_ call: CAPPluginCall) {
        guard let slug = call.getString("slug"), let name = call.getString("name") else { return call.reject("slug and name required") }
        DispatchQueue.main.async {
            let a = NSUserActivity(activityType: Self.resortActivity)
            a.title = "\(name) snow forecast"
            a.userInfo = ["path": "/resorts/\(slug)"]
            a.webpageURL = URL(string: "https://snowway.app/resorts/\(slug)")
            a.isEligibleForSearch = true
            a.isEligibleForPrediction = true
            a.persistentIdentifier = "resort-\(slug)"
            a.keywords = [name, "snow", "forecast", "powder", "ski"]
            let attributes = CSSearchableItemAttributeSet(contentType: .content)
            attributes.contentDescription = "Snow forecast, weather and powder alerts for \(name)."
            a.contentAttributeSet = attributes
            self.activity = a
            a.becomeCurrent()
            WidgetCenter.shared.reloadAllTimelines()
            call.resolve()
        }
    }
}
