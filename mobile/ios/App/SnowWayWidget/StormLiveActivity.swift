import ActivityKit
import SwiftUI
import WidgetKit

// The storm tracker on the Lock Screen and in the Dynamic Island. Tapping opens the resort in the app.
struct StormLiveActivity: Widget {
    private let snow = Color(red: 103 / 255, green: 232 / 255, blue: 249 / 255)

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StormAttributes.self) { context in
            HStack(spacing: 14) {
                Image(systemName: "cloud.snow.fill").font(.title).foregroundStyle(snow)
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.headline).font(.caption.bold()).foregroundStyle(.white.opacity(0.7))
                    Text(context.state.resortName).font(.headline).foregroundStyle(.white)
                    Text("\(context.state.next7DaysIn)\" in the next 7 days").font(.caption).foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(context.state.next3DaysIn)\"").font(.system(size: 34, weight: .heavy, design: .rounded)).foregroundStyle(snow)
                        .contentTransition(.numericText())
                    Text("next 3 days").font(.caption2).foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding()
            .activityBackgroundTint(Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255))
            .widgetURL(URL(string: "snowway://resorts/\(context.attributes.slug)"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.resortName, systemImage: "snowflake").font(.headline).lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.next3DaysIn)\"").font(.title.bold()).foregroundStyle(snow)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.state.headline) · \(context.state.next7DaysIn)\" this week").font(.caption).foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "snowflake").foregroundStyle(snow)
            } compactTrailing: {
                Text("\(context.state.next3DaysIn)\"").foregroundStyle(snow)
            } minimal: {
                Text("\(context.state.next3DaysIn)\"").font(.caption2).foregroundStyle(snow)
            }
            .widgetURL(URL(string: "snowway://resorts/\(context.attributes.slug)"))
        }
    }
}
