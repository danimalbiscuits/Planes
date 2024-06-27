import Foundation

// Model
struct Flight: Identifiable {
    let id = UUID()
    let callsign: String
    let icao24: String
    var ICAOTypeCode: String?
    var Manufacturer: String?
    var RegisteredOwners: String?
    var longitude: Double?
    var latitude: Double?
}
