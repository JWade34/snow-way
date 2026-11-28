import AppIntents
import Foundation

// A page the app should open once its web view is ready (set by intents that launch the app).
enum PendingOpen {
    static var path: String?
}

// Opens the app on the powder rankings. Used by the Control Center button; it runs in the app, not the widget.
@available(iOS 16.0, *)
struct OpenPowderIntent: AppIntent {
    static var title: LocalizedStringResource = "Open powder rankings"
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        PendingOpen.path = "/resorts"
        NotificationCenter.default.post(name: Notification.Name("snowWayOpenPath"), object: "/resorts")
        return .result()
    }
}
