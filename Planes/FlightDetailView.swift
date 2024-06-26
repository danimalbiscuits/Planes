import SwiftUI

struct FlightDetailView: View {
    var flight: Flight

    var body: some View {
        VStack {
            Text("Callsign: \(flight.callsign)")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("Flight Details")
    }
}
