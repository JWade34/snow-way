import ActivityKit
import Foundation

// The storm tracker Live Activity. snowway.app starts and updates it by push (see app/services/storm_tracker.rb),
// so these names must match the JSON the server sends.
struct StormAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var resortName: String
        var next3DaysIn: Int
        var next7DaysIn: Int
        var headline: String
        var updatedAt: Date
    }

    var slug: String
    var resortName: String
}
