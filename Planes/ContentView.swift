import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlightViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.flights) { flight in
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
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            .refreshable {
                viewModel.fetchFlights()
            }
            .navigationTitle("LA Flights")
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

