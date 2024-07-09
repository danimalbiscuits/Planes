import Foundation
import MapKit

struct FlightAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let flight: Flight
}
