import SwiftUI
import MapKit

struct FlightDetailView: View {
    var flight: Flight
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(flight.callsign)")
                .font(.title)
                .padding(.bottom, 10)

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

            if let latitude = flight.latitude, let longitude = flight.longitude {
                Map(position: $position) {
                    Marker(flight.callsign, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                }
                .frame(height: 200)
                .onAppear {
                    position = MapCameraPosition.region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                    )
                }
                .padding(.bottom, 10)
            } else {
                Text("Location: Unknown")
                    .padding(.bottom, 5)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Flight Details")
        .onAppear {
            // Fetch data if necessary when the detail view appears
        }
    }
}

struct FlightDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FlightDetailView(flight: Flight(callsign: "Example", icao24: "abc123", ICAOTypeCode: "A320", Manufacturer: "Airbus", RegisteredOwners: "Airline", longitude: 174.898370, latitude: -41.109540, velocity: 250.0, geo_altitude: 10000.0))
    }
}
