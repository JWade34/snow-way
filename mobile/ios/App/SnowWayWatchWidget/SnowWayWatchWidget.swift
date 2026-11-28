import SwiftUI
import WidgetKit

// Watch face complications: the resort getting the most snow in the next 7 days. Refreshes about every hour.

struct TopEntry: TimelineEntry {
    let date: Date
    let resort: SnowWayAPI.Resort?
}

struct TopProvider: TimelineProvider {
    static let sample = SnowWayAPI.Resort(slug: "alta", name: "Alta", region: "Utah, USA", next3DaysIn: 14, next7DaysIn: 22, tempF: 18)

    func placeholder(in context: Context) -> TopEntry { TopEntry(date: Date(), resort: Self.sample) }
    func getSnapshot(in context: Context, completion: @escaping (TopEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<TopEntry>) -> Void) {
        Task {
            let top = try? await SnowWayAPI.powder(limit: 1).first
            completion(Timeline(entries: [TopEntry(date: Date(), resort: top)], policy: .after(Date().addingTimeInterval(60 * 60))))
        }
    }
}

struct TopView: View {
    @Environment(\.widgetFamily) var family
    let entry: TopEntry

    private var inches: Int { entry.resort?.next7DaysIn ?? 0 }
    private var name: String { entry.resort?.name ?? "Snow Way" }

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("❄︎ \(name) \(inches)\"")
        case .accessoryCircular:
            VStack(spacing: 0) {
                Image(systemName: "snowflake").font(.caption2)
                Text("\(inches)\"").font(.headline.bold()).minimumScaleFactor(0.6)
            }
        case .accessoryCorner:
            Image(systemName: "snowflake").font(.title3)
                .widgetLabel { Text("\(name) \(inches)\"") }
        default:
            VStack(alignment: .leading, spacing: 1) {
                Label("Most snow this week", systemImage: "snowflake").font(.caption2).foregroundStyle(.secondary)
                Text(name).font(.headline).lineLimit(1)
                Text("\(inches)\" next 7 days").font(.body.bold()).foregroundStyle(Color(red: 103 / 255, green: 232 / 255, blue: 249 / 255))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

@main
struct SnowWayWatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PowderNowWatch", provider: TopProvider()) { entry in
            TopView(entry: entry).containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Powder Now")
        .description("The ski resort getting the most snow this week.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
    }
}
