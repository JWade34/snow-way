import AppIntents
import CoreLocation
import SwiftUI

// Siri and Shortcuts. These work with no setup: "Hey Siri, where's the powder in Snow Way?"
// They also show up in the Shortcuts app, Spotlight and the Action button.

@available(iOS 16.0, *)
struct WheresThePowderIntent: AppIntent {
    static var title: LocalizedStringResource = "Where's the powder?"
    static var description = IntentDescription("The ski resorts getting the most snow in the next 7 days.")

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let pass = UserDefaults.standard.string(forKey: SnowWayAPI.passKey)
        let top = try await SnowWayAPI.powder(limit: 3, pass: pass)
        guard let first = top.first else {
            return .result(dialog: "I couldn't get the forecast right now.", view: PowderSnippet(resorts: []))
        }
        let onPass = pass.flatMap { SnowWayAPI.passNames[$0] }.map { "On your \($0) pass, " } ?? ""
        var line = "\(onPass)\(first.name) leads with \(first.next7DaysIn ?? 0) inches in the next 7 days."
        if top.count > 1 {
            line += " Then " + top.dropFirst().map { "\($0.name) with \($0.next7DaysIn ?? 0)" }.joined(separator: ", and ") + "."
        }
        return .result(dialog: IntentDialog(stringLiteral: line), view: PowderSnippet(resorts: top))
    }
}

@available(iOS 16.0, *)
struct PowderNearMeIntent: AppIntent {
    static var title: LocalizedStringResource = "Powder near me"
    static var description = IntentDescription("The snowiest ski resorts within driving distance of where you are.")

    @Parameter(title: "Within miles", default: 250, inclusiveRange: (50, 800))
    var miles: Int

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let here = try await OneShotLocation().get()
        let top = try await SnowWayAPI.powder(limit: 3, near: (here.coordinate.latitude, here.coordinate.longitude), miles: miles)
        guard let first = top.first else {
            return .result(dialog: "I didn't find a ski resort within \(miles) miles.", view: PowderSnippet(resorts: []))
        }
        let line = "Closest powder: \(first.name), \(first.miles ?? 0) miles away, with \(first.next7DaysIn ?? 0) inches in the next 7 days."
        return .result(dialog: IntentDialog(stringLiteral: line), view: PowderSnippet(resorts: top))
    }
}

// Gets the phone's location once, for "Powder near me". Used on the device only to pick resorts; the
// coordinates go to snowway.app in that one request and aren't stored.
@MainActor
final class OneShotLocation: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    func get() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { cont in
            continuation = cont
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
            if manager.authorizationStatus == .notDetermined { manager.requestWhenInUseAuthorization() } else { manager.requestLocation() }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
            case .denied, .restricted: self.finish(.failure(CLError(.denied)))
            default: break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in if let l = locations.last { self.finish(.success(l)) } }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in self.finish(.failure(error)) }
    }

    private func finish(_ result: Result<CLLocation, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
}

@available(iOS 16.0, *)
struct ResortSnowIntent: AppIntent {
    static var title: LocalizedStringResource = "Snow forecast for a resort"
    static var description = IntentDescription("How much snow a ski resort is forecast to get.")

    @Parameter(title: "Resort", requestValueDialog: "Which resort?")
    var resort: ResortEntity

    static var parameterSummary: some ParameterSummary { Summary("Snow forecast for \(\.$resort)") }

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView & ReturnsValue<Int> {
        let r = try await SnowWayAPI.resort(resort.id)
        return .result(value: r.next7DaysIn ?? 0, dialog: IntentDialog(stringLiteral: r.spokenForecast), view: PowderSnippet(resorts: [r]))
    }
}

@available(iOS 16.0, *)
struct OpenResortIntent: AppIntent {
    static var title: LocalizedStringResource = "Open a resort in Snow Way"
    static var openAppWhenRun = true

    @Parameter(title: "Resort")
    var resort: ResortEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        SnowWayViewController.open(path: "/resorts/\(resort.id)")
        return .result()
    }
}

@available(iOS 16.0, *)
struct SnowWayShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: WheresThePowderIntent(), phrases: [
            "Where's the powder in \(.applicationName)",
            "Where is it snowing in \(.applicationName)",
            "\(.applicationName) powder report",
            "Ask \(.applicationName) where the powder is"
        ], shortTitle: "Where's the powder?", systemImageName: "snowflake")
        AppShortcut(intent: PowderNearMeIntent(), phrases: [
            "Powder near me in \(.applicationName)",
            "Where's the closest powder in \(.applicationName)"
        ], shortTitle: "Powder near me", systemImageName: "location")
        AppShortcut(intent: ResortSnowIntent(), phrases: [
            "How much snow is \(\.$resort) getting in \(.applicationName)",
            "\(.applicationName) forecast for \(\.$resort)",
            "Snow at \(\.$resort) in \(.applicationName)"
        ], shortTitle: "Resort forecast", systemImageName: "cloud.snow")
        AppShortcut(intent: OpenResortIntent(), phrases: [
            "Open \(\.$resort) in \(.applicationName)"
        ], shortTitle: "Open a resort", systemImageName: "mountain.2")
    }
}

// The card Siri shows under its answer.
@available(iOS 16.0, *)
struct PowderSnippet: View {
    let resorts: [SnowWayAPI.Resort]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(resorts, id: \.slug) { r in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(r.name).font(.headline)
                        Text(r.region).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(r.next7DaysIn ?? 0)\"").font(.title2.bold()).foregroundStyle(.cyan)
                        Text("next 7 days").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
    }
}
