import Foundation

struct Flight: Identifiable {
    let id = UUID()
    let callsign: String
    let icao24: String
    var ICAOTypeCode: String?
    var Manufacturer: String?
    var RegisteredOwners: String?
    var longitude: Double?
    var latitude: Double?
    var velocity: Float?
    var geo_altitude: Float?
    var true_track: Float? // Added true_track field
}
