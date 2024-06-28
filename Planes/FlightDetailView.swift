import SwiftUI

struct FlightDetailView: View {
    var flight: Flight

    var body: some View {
        VStack(alignment: .leading) {
            Text("Callsign: \(flight.callsign)")
                .font(.largeTitle)
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
        FlightDetailView(flight: Flight(callsign: "Example", icao24: "abc123", ICAOTypeCode: "A320", Manufacturer: "Airbus", RegisteredOwners: "Airline", velocity: 250.0, geo_altitude: 10000.0))
    }
}

