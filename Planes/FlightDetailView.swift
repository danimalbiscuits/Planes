import SwiftUI
import MapKit

struct FlightDetailView: View {
    let flight: Flight
    
    var body: some View {
        VStack {
            Map()
            Text("Hello")
            
        }
    }
}

struct FlightDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FlightDetailView(flight: Flight(callsign: "Sample CallSign", icao24: "Sample ICAO24"))
    }
}

