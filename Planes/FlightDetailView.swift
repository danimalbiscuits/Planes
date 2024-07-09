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
        VStack {
            VStack {
                Text("\(flight.callsign)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 1)
                
                Text("\(flight.Manufacturer ?? "Unknown") - \(flight.ICAOTypeCode ?? "Unknown")")
                    .font(.title2)
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity) // Center align horizontally
            
            if let latitude = flight.latitude, let longitude = flight.longitude {
                Map(position: $cameraPosition) {
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                        VStack {
                            Image(systemName: "airplane")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(Double((flight.true_track ?? 0)) - 90)) // Rotate the plane based on true_track
                        }
                    }
                }
                .ignoresSafeArea(edges: .horizontal) // Ignore horizontal safe area
                .frame(width: 380, height: 200)
                .onAppear {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2) // Zoomed in
                        )
                    )
                }
                .padding(.bottom, 10)
            } else {
                Text("Location: Unknown")
                    .padding(.bottom, 5)
            }

            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text("Speed:")
                        .fontWeight(.bold)
                    if let velocity = flight.velocity {
                        let velocityKmH = round(velocity * 3.6)
                        Text("\(Int(velocityKmH)) km/h")
                            .padding(.bottom, 5)
                    } else {
                        Text("Unknown")
                            .padding(.bottom, 5)
                    }
                }

                Spacer()

                VStack(alignment: .center) {
                    Text("Altitude:")
                        .fontWeight(.bold)
                    if let geoAltitude = flight.geo_altitude {
                        let roundedGeoAltitude = round(geoAltitude)
                        Text("\(Int(roundedGeoAltitude)) m")
                            .padding(.bottom, 5)
                    } else {
                        Text("Unknown")
                            .padding(.bottom, 5)
                    }
                }
                Spacer()
            }
            
            VStack(alignment: .center) {
                Text(flight.RegisteredOwners ?? "Unknown")
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
            }
            .frame(maxWidth: .infinity) // Center align horizontally

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
