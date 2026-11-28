import Foundation

// Reads snowway.app's small app feed (/api/app/...). Shared by the app (Siri, Shortcuts) and the widgets.
enum SnowWayAPI {
    static let base = URL(string: "https://snowway.app")!
    static let passKey = "snowway.pass"
    static let passNames = ["epic": "Epic", "ikon": "Ikon", "indy": "Indy", "mountain_collective": "Mountain Collective"]

    struct Resort: Codable, Hashable {
        let slug: String
        let name: String
        let region: String
        var next3DaysIn: Int?
        var next7DaysIn: Int?
        var tempF: Int?
        var miles: Int?

        enum CodingKeys: String, CodingKey {
            case slug, name, region, miles
            case next3DaysIn = "next_3_days_in"
            case next7DaysIn = "next_7_days_in"
            case tempF = "temp_f"
        }
    }

    private struct ResortList: Codable { let resorts: [Resort] }

    // pass: epic, ikon, indy, mountain_collective (nil = every resort). near: only resorts within `miles`.
    static func powder(limit: Int = 5, pass: String? = nil, near: (lat: Double, lng: Double)? = nil, miles: Int = 300) async throws -> [Resort] {
        var path = "/api/app/powder?limit=\(limit)"
        if let pass, passNames[pass] != nil { path += "&pass=\(pass)" }
        if let near { path += "&lat=\(near.lat)&lng=\(near.lng)&miles=\(miles)" }
        return try await get(path, as: ResortList.self).resorts
    }

    static func search(_ query: String) async throws -> [Resort] {
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return try await get("/api/app/resorts?q=\(q)", as: ResortList.self).resorts
    }

    static func resorts(slugs: [String]) async throws -> [Resort] {
        try await get("/api/app/resorts?slugs=\(slugs.joined(separator: ","))", as: ResortList.self).resorts
    }

    static func resort(_ slug: String) async throws -> Resort {
        try await get("/api/app/resorts/\(slug)", as: Resort.self)
    }

    static func pageURL(_ path: String) -> URL {
        var parts = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        parts.queryItems = [URLQueryItem(name: "utm_source", value: "ios_app"), URLQueryItem(name: "utm_medium", value: "app")]
        return parts.url!
    }

    private static func get<T: Decodable>(_ path: String, as type: T.Type) async throws -> T {
        var request = URLRequest(url: URL(string: path, relativeTo: base)!)
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension SnowWayAPI.Resort {
    // "12 inches in the next 3 days, 20 this week" in words Siri reads naturally.
    var spokenForecast: String {
        let three = next3DaysIn ?? 0, week = next7DaysIn ?? 0
        if week == 0 { return "\(name) has no new snow in the forecast this week." }
        let threeText = three > 0 ? "\(three) \(three == 1 ? "inch" : "inches") in the next 3 days and " : ""
        return "\(name) is forecast to get \(threeText)\(week) \(week == 1 ? "inch" : "inches") in the next 7 days."
    }
}
