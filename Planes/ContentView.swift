import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlightViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.sortedFlights) { flight in
                NavigationLink(destination: FlightDetailView(flight: flight)) {
                    HStack(alignment: .top) {
                        Image(systemName: "airplane")
                            .foregroundColor(.blue)
                            .padding(.trailing, 5)
                            .symbolEffect(.pulse)
                        VStack(alignment: .leading) {
                            if let registeredOwners = flight.RegisteredOwners {
                                Text("\(registeredOwners)")
                            }
                            Text("\(flight.callsign)")
                            if let manufacturer = flight.Manufacturer, let icaoTypeCode = flight.ICAOTypeCode {
                                Text("\(manufacturer) - \(icaoTypeCode)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .refreshable {
                viewModel.fetchFlights()
            }
            .navigationTitle("Flights")
            .onAppear {
                viewModel.fetchFlights()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
