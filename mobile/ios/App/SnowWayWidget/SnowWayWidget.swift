import AppIntents
import SwiftUI
import WidgetKit

// Home Screen and Lock Screen widgets. "Powder Now" shows the snowiest resorts; "My Resort" shows one resort.
// Both read snowway.app's app feed and refresh about every hour. Tapping opens the page in the app.

struct PowderEntry: TimelineEntry {
    let date: Date
    let resorts: [SnowWayAPI.Resort]
    var threeDay = false // tappable toggle: next 3 days instead of next 7
}

// Tapping "7 days / 3 days" on a widget flips the window. Runs in the widget, no app launch.
struct ToggleWindowIntent: AppIntent {
    static var title: LocalizedStringResource = "Switch forecast window"
    static let key = "snowway.widget.threeDay"
    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: Self.key), forKey: Self.key)
        return .result()
    }
}

private func threeDay() -> Bool { UserDefaults.standard.bool(forKey: ToggleWindowIntent.key) }

private let sample = [
    SnowWayAPI.Resort(slug: "alta", name: "Alta", region: "Utah, USA", next3DaysIn: 14, next7DaysIn: 22, tempF: 18),
    SnowWayAPI.Resort(slug: "jackson-hole", name: "Jackson Hole", region: "Wyoming, USA", next3DaysIn: 10, next7DaysIn: 18, tempF: 15),
    SnowWayAPI.Resort(slug: "mammoth-mountain", name: "Mammoth", region: "California, USA", next3DaysIn: 8, next7DaysIn: 15, tempF: 24)
]

private func nextRefresh() -> Date { Date().addingTimeInterval(60 * 60) }

struct PowderProvider: TimelineProvider {
    func placeholder(in context: Context) -> PowderEntry { PowderEntry(date: Date(), resorts: sample) }
    func getSnapshot(in context: Context, completion: @escaping (PowderEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PowderEntry>) -> Void) {
        Task {
            var resorts = (try? await SnowWayAPI.powder(limit: 4)) ?? []
            if threeDay() { resorts.sort { ($0.next3DaysIn ?? 0) > ($1.next3DaysIn ?? 0) } }
            completion(Timeline(entries: [PowderEntry(date: Date(), resorts: resorts, threeDay: threeDay())], policy: .after(nextRefresh())))
        }
    }
}

struct ResortProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PowderEntry { PowderEntry(date: Date(), resorts: [sample[0]]) }
    func snapshot(for configuration: PickResortIntent, in context: Context) async -> PowderEntry { placeholder(in: context) }
    func timeline(for configuration: PickResortIntent, in context: Context) async -> Timeline<PowderEntry> {
        var resorts: [SnowWayAPI.Resort] = []
        if let slug = configuration.resort?.id, let r = try? await SnowWayAPI.resort(slug) {
            resorts = [r]
        } else if let top = try? await SnowWayAPI.powder(limit: 1) {
            resorts = top
        }
        return Timeline(entries: [PowderEntry(date: Date(), resorts: resorts, threeDay: threeDay())], policy: .after(nextRefresh()))
    }
}

private let ink = Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255)
private let snow = Color(red: 103 / 255, green: 232 / 255, blue: 249 / 255)

private func link(_ r: SnowWayAPI.Resort?) -> URL { URL(string: r.map { "snowway://resorts/\($0.slug)" } ?? "snowway:///")! }

struct PowderView: View {
    @Environment(\.widgetFamily) var family
    let entry: PowderEntry
    let title: String

    private func inches(_ r: SnowWayAPI.Resort) -> Int { (entry.threeDay ? r.next3DaysIn : r.next7DaysIn) ?? 0 }
    private var windowLabel: String { entry.threeDay ? "Next 3 days" : "Next 7 days" }

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.resorts.first.map { "❄︎ \($0.name) \($0.next7DaysIn ?? 0)\"" } ?? "Snow Way")
        case .accessoryCircular:
            VStack(spacing: 0) {
                Image(systemName: "snowflake").font(.caption2)
                Text("\(entry.resorts.first?.next7DaysIn ?? 0)\"").font(.headline.bold())
            }
            .widgetURL(link(entry.resorts.first))
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Label(title, systemImage: "snowflake").font(.caption2.bold())
                ForEach(entry.resorts.prefix(2), id: \.slug) { r in
                    Text("\(r.name) \(r.next7DaysIn ?? 0)\"").font(.caption).lineLimit(1)
                }
            }
            .widgetURL(link(entry.resorts.first))
        default:
            content
        }
    }

    // "Next 7 days ⇄" button: tap to flip to the next 3 days.
    private var toggle: some View {
        Button(intent: ToggleWindowIntent()) {
            Label(windowLabel, systemImage: "arrow.left.arrow.right").font(.caption2).foregroundStyle(.white.opacity(0.6))
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        let count = family == .systemSmall ? 1 : (family == .systemLarge ? 4 : 3)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "snowflake").foregroundStyle(snow)
                Text(title).font(.caption.bold()).foregroundStyle(.white.opacity(0.8))
                Spacer()
            }
            if entry.resorts.isEmpty {
                Spacer()
                Text("Open Snow Way for the forecast").font(.caption).foregroundStyle(.white.opacity(0.7))
                Spacer()
            } else if count == 1, let r = entry.resorts.first {
                Spacer(minLength: 0)
                Text("\(inches(r))\"").font(.system(size: 40, weight: .heavy, design: .rounded)).foregroundStyle(snow)
                    .contentTransition(.numericText())
                Text(r.name).font(.headline).foregroundStyle(.white).lineLimit(1)
                toggle
            } else {
                ForEach(entry.resorts.prefix(count), id: \.slug) { r in
                    Link(destination: link(r)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(r.name).font(.subheadline.bold()).foregroundStyle(.white).lineLimit(1)
                                Text(r.region).font(.caption2).foregroundStyle(.white.opacity(0.6)).lineLimit(1)
                            }
                            Spacer()
                            Text("\(inches(r))\"").font(.title3.bold()).foregroundStyle(snow).contentTransition(.numericText())
                        }
                    }
                }
                Spacer(minLength: 0)
                toggle
            }
        }
        .widgetURL(link(count == 1 ? entry.resorts.first : nil))
        .containerBackground(for: .widget) { ink }
    }
}

struct PowderNowWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PowderNow", provider: PowderProvider()) { entry in
            PowderView(entry: entry, title: "Powder now")
        }
        .configurationDisplayName("Powder Now")
        .description("The ski resorts getting the most snow in the next 7 days.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline, .accessoryCircular])
    }
}

struct MyResortWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "MyResort", intent: PickResortIntent.self, provider: ResortProvider()) { entry in
            PowderView(entry: entry, title: entry.resorts.first?.name ?? "My resort")
        }
        .configurationDisplayName("My Resort")
        .description("The snow forecast for your resort. Press and hold to pick it.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryInline, .accessoryCircular])
    }
}

// Control Center and Action button: "Where's the powder" opens the snowiest resorts (iOS 18).
@available(iOS 18.0, *)
struct PowderControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "app.snowway.powder-control") {
            ControlWidgetButton(action: OpenPowderIntent()) {
                Label("Where's the powder", systemImage: "snowflake")
            }
        }
        .displayName("Where's the powder")
        .description("Opens Snow Way's powder rankings.")
    }
}

@main
struct SnowWayWidgets: WidgetBundle {
    var body: some Widget {
        PowderNowWidget()
        MyResortWidget()
        StormLiveActivity()
        if #available(iOS 18.0, *) { PowderControl() }
    }
}
