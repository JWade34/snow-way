import ActivityKit
import Foundation

// Sends snowway.app the tokens it needs to run storm trackers on this iPhone:
// one to start a tracker by push (iOS 17.2+), and one per running tracker to update it.
enum StormActivityManager {
    static let deviceTokenKey = "snowway.apnsToken"
    private static var started = false
    private static var startToken: String?

    // Called at launch and again when the APNs device token arrives (then it resends the start token).
    static func start() {
        if let startToken { post("/push_subscriptions/live_start", ["start_token": startToken]) }
        guard !started, #available(iOS 17.2, *) else { return }
        started = true
        Task {
            for await data in Activity<StormAttributes>.pushToStartTokenUpdates {
                startToken = hex(data)
                post("/push_subscriptions/live_start", ["start_token": hex(data)])
            }
        }
        Task {
            for activity in Activity<StormAttributes>.activities { watch(activity) }
            for await activity in Activity<StormAttributes>.activityUpdates { watch(activity) }
        }
    }

    @available(iOS 16.2, *)
    private static func watch(_ activity: Activity<StormAttributes>) {
        Task {
            for await data in activity.pushTokenUpdates {
                post("/push_subscriptions/live_activity", ["slug": activity.attributes.slug, "push_token": hex(data)])
            }
        }
    }

    private static func hex(_ data: Data) -> String { data.map { String(format: "%02x", $0) }.joined() }

    // Needs the device's APNs token, saved by AppDelegate. Without notifications on, there's nothing to start.
    private static func post(_ path: String, _ body: [String: String]) {
        guard let device = UserDefaults.standard.string(forKey: deviceTokenKey) else { return }
        var request = URLRequest(url: URL(string: path, relativeTo: SnowWayAPI.base)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body.merging(["endpoint": device]) { a, _ in a })
        URLSession.shared.dataTask(with: request).resume()
    }
}
