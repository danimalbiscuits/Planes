import SwiftUI
import MapKit

struct FlightDetailView: View {
    var flight: Flight
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        )
    )

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(flight.callsign) \(flight.Manufacturer ?? "Unknown") - \(flight.ICAOTypeCode ?? "Unknown")")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            if let latitude = flight.latitude, let longitude = flight.longitude {
                Map(position: $cameraPosition) {
                    Marker(flight.callsign, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                }
                .ignoresSafeArea(edges: .horizontal) // Ignore horizontal safe area
                .frame(width: 380, height: 200)
                .onAppear {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
                        )
                    )
                }
                .padding(.bottom, 10)
            } else {
                Text("Location: Unknown")
                    .padding(.bottom, 5)
            }

            if let velocity = flight.velocity {
                let velocityKmH = round(velocity * 3.6)
                Text("Velocity: \(Int(velocityKmH)) km/h")
                    .padding(.bottom, 5)
            } else {
                Text("Velocity: Unknown")
                    .padding(.bottom, 5)
            }

            if let geoAltitude = flight.geo_altitude {
                let roundedGeoAltitude = round(geoAltitude)
                Text("Geo Altitude: \(Int(roundedGeoAltitude)) m")
                    .padding(.bottom, 5)
            } else {
                Text("Geo Altitude: Unknown")
                    .padding(.bottom, 5)
            }

            if let trueTrack = flight.true_track {
                Text("True Track: \(trueTrack)°")
                    .padding(.bottom, 5)
            } else {
                Text("True Track: Unknown")
                    .padding(.bottom, 5)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Flight Details")
    }
}

struct FlightDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FlightDetailView(flight: Flight(callsign: "ANZ246", icao24: "abc123", ICAOTypeCode: "A320", Manufacturer: "Airbus", RegisteredOwners: "Airline", longitude: -122.4194, latitude: 37.7749, velocity: 250.0, geo_altitude: 10000.0, true_track: 90.0))
    }
}
