import SwiftUI
import WidgetKit

// Apple Watch app: the snowiest resorts this week, optionally only on your pass. Reads snowway.app's app feed.
@main
struct SnowWayWatchApp: App {
    var body: some Scene {
        WindowGroup { PowderList() }
    }
}

let snowCyan = Color(red: 103 / 255, green: 232 / 255, blue: 249 / 255)

struct PowderList: View {
    @AppStorage(SnowWayAPI.passKey) private var pass = ""
    @State private var resorts: [SnowWayAPI.Resort] = []
    @State private var failed = false
    @State private var loading = true

    var body: some View {
        NavigationStack {
            List {
                Picker("Pass", selection: $pass) {
                    Text("All resorts").tag("")
                    ForEach(SnowWayAPI.passNames.sorted(by: { $0.value < $1.value }), id: \.key) { key, name in
                        Text(name).tag(key)
                    }
                }
                if loading && resorts.isEmpty {
                    ProgressView().frame(maxWidth: .infinity)
                } else if failed && resorts.isEmpty {
                    Text("Can't reach Snow Way. Check your connection.").font(.footnote).foregroundStyle(.secondary)
                } else {
                    ForEach(Array(resorts.enumerated()), id: \.element.slug) { index, resort in
                        NavigationLink(value: resort) { ResortRow(rank: index + 1, resort: resort) }
                    }
                }
            }
            .navigationTitle("Powder")
            .navigationDestination(for: SnowWayAPI.Resort.self) { ResortDetail(resort: $0) }
            .refreshable { await load() }
            .task(id: pass) { await load() }
        }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            resorts = try await SnowWayAPI.powder(limit: 10, pass: pass.isEmpty ? nil : pass)
            failed = false
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            failed = true
        }
    }
}

struct ResortRow: View {
    let rank: Int
    let resort: SnowWayAPI.Resort

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text("\(rank). \(resort.name)").font(.headline).lineLimit(2)
                Text(resort.region).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 4)
            Text("\(resort.next7DaysIn ?? 0)\"").font(.title3.bold()).foregroundStyle(snowCyan)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rank). \(resort.spokenForecast)")
    }
}

struct ResortDetail: View {
    let resort: SnowWayAPI.Resort

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(resort.region).font(.caption2).foregroundStyle(.secondary)
                Text("\(resort.next7DaysIn ?? 0)\"").font(.system(size: 44, weight: .heavy, design: .rounded)).foregroundStyle(snowCyan)
                Text("next 7 days").font(.caption).foregroundStyle(.secondary)
                Divider()
                stat("Next 3 days", "\(resort.next3DaysIn ?? 0)\"")
                if let t = resort.tempF { stat("Now", "\(t)°F") }
                if let m = resort.miles { stat("Distance", "\(m) mi") }
                Text("Forecast at mid-mountain. Check the resort's report before you drive.")
                    .font(.footnote).foregroundStyle(.secondary).padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(resort.name)
    }

    private func stat(_ label: String, _ value: String) -> some View {
        HStack { Text(label).foregroundStyle(.secondary); Spacer(); Text(value).bold() }.font(.body)
    }
}
