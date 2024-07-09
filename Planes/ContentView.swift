import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = FlightViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -41.109540, longitude: 174.898370),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )

    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: false, userTrackingMode: nil, annotationItems: viewModel.annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    NavigationLink(destination: FlightDetailView(flight: annotation.flight)) {
                        VStack {
                            Image(systemName: "airplane")
                                .font(.system(size: 25)) // Increase the size of the plane icon
                                .foregroundColor(.blue)
                                .padding(.bottom, 0)
                                .symbolEffect(.pulse)
                            Text(annotation.title ?? "Unknown")
                                .font(.caption2)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .all) // Ignore the safe area
            .navigationTitle("Flights")
            .onAppear {
                viewModel.fetchFlights()
            }
            .refreshable {
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
