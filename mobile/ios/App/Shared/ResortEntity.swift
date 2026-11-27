import AppIntents
import Foundation

// A ski resort as Siri, Shortcuts and the widget picker see it. Looked up live from snowway.app.
@available(iOS 16.0, *)
struct ResortEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Ski Resort")
    static var defaultQuery = ResortQuery()

    let id: String // slug
    let name: String
    let region: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(region)")
    }

    init(id: String, name: String, region: String) { self.id = id; self.name = name; self.region = region }
    init(_ resort: SnowWayAPI.Resort) { self.init(id: resort.slug, name: resort.name, region: resort.region) }
}

@available(iOS 16.0, *)
struct ResortQuery: EntityStringQuery {
    func entities(for identifiers: [ResortEntity.ID]) async throws -> [ResortEntity] {
        guard !identifiers.isEmpty else { return [] }
        return try await SnowWayAPI.resorts(slugs: identifiers).map(ResortEntity.init)
    }

    func entities(matching string: String) async throws -> [ResortEntity] {
        try await SnowWayAPI.search(string).map(ResortEntity.init)
    }

    // The snowiest resorts right now, so the picker opens on the interesting ones.
    func suggestedEntities() async throws -> [ResortEntity] {
        try await SnowWayAPI.search("").map(ResortEntity.init)
    }
}

// The widget's settings: which resort to show.
@available(iOS 17.0, *)
struct PickResortIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Pick a resort"
    static var description = IntentDescription("Shows the snow forecast for one resort.")

    @Parameter(title: "Resort")
    var resort: ResortEntity?
}
