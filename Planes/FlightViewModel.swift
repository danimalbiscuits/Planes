import SwiftUI
import Combine
import CoreLocation

class FlightViewModel: ObservableObject {
    @Published var flights: [Flight] = []
    @Published var sortedFlights: [Flight] = []
    @Published var annotations: [FlightAnnotation] = []

    private var cancellables = Set<AnyCancellable>()
    
    // Fixed coordinates
    let fixedLocation = CLLocation(latitude: -41.109540, longitude: 174.898370)

    init() {
        fetchFlights()
    }

    func fetchFlights() {
        let urlString = "https://opensky-network.org/api/states/all?lamin=-41.885921&lomin=172.177734&lamax=-36.102376&lomax=179.868164"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: OpenSkyResponse.self, decoder: JSONDecoder())
            .catch { _ in Just(OpenSkyResponse(states: [])) }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching flights: \(error)")
                }
            }, receiveValue: { response in
                print("API Response: \(response)")

                let newFlights = response.states.compactMap { state -> Flight? in
                    guard state.count > 13 else { return nil }
                    let icao24 = state[0] as? String ?? "Unknown"
                    let callsign = state[1] as? String ?? "Unknown"
                    let longitude = state[5] as? Double
                    let latitude = state[6] as? Double
                    let velocity = state[9] as? Double
                    let true_track = state[10] as? Double // Parsing true_track
                    let geo_altitude = state[12] as? Double

                    return Flight(callsign: callsign, icao24: icao24, longitude: longitude, latitude: latitude, velocity: velocity != nil ? Float(velocity!) : nil, geo_altitude: geo_altitude != nil ? Float(geo_altitude!) : nil, true_track: true_track != nil ? Float(true_track!) : nil)
                }
                DispatchQueue.main.async {
                    self.flights = newFlights
                    print("Fetched flights: \(self.flights.count)")
                    self.fetchAircraftDetails()
                }
            })
            .store(in: &cancellables)
    }

    func fetchAircraftDetails() {
        for (index, flight) in flights.enumerated() {
            let url = URL(string: "https://hexdb.io/api/v1/aircraft/\(flight.icao24)")!
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { $0.data }
                .decode(type: AircraftDetails.self, decoder: JSONDecoder())
                .replaceError(with: AircraftDetails(ICAOTypeCode: "Unknown", Manufacturer: "Unknown", RegisteredOwners: "Unknown"))
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching aircraft details: \(error)")
                    }
                }, receiveValue: { details in
                    DispatchQueue.main.async {
                        self.flights[index].ICAOTypeCode = details.ICAOTypeCode
                        self.flights[index].Manufacturer = details.Manufacturer
                        self.flights[index].RegisteredOwners = details.RegisteredOwners
                        self.sortFlightsByDistance()
                        self.updateAnnotations()
                    }
                })
                .store(in: &cancellables)
        }
    }

    func sortFlightsByDistance() {
        self.sortedFlights = self.flights.sorted {
            let location1 = CLLocation(latitude: $0.latitude ?? 0.0, longitude: $0.longitude ?? 0.0)
            let location2 = CLLocation(latitude: $1.latitude ?? 0.0, longitude: $1.longitude ?? 0.0)
            return location1.distance(from: fixedLocation) < location2.distance(from: fixedLocation)
        }
        print("Sorted flights count: \(self.sortedFlights.count)")
    }

    func updateAnnotations() {
        self.annotations = self.sortedFlights.compactMap { flight in
            guard let latitude = flight.latitude, let longitude = flight.longitude else { return nil }
            return FlightAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                title: flight.callsign,
                subtitle: flight.icao24,
                flight: flight
            )
        }
    }
}

// Response structure for OpenSky API
struct OpenSkyResponse: Decodable {
    let states: [[Any]]

    enum CodingKeys: String, CodingKey {
        case states
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var statesContainer = try container.nestedUnkeyedContainer(forKey: .states)
        
        var tempStates = [[Any]]()
        
        while !statesContainer.isAtEnd {
            var stateArrayContainer = try statesContainer.nestedUnkeyedContainer()
            var stateArray = [Any]()
            
            while !stateArrayContainer.isAtEnd {
                if let stringValue = try? stateArrayContainer.decode(String.self) {
                    stateArray.append(stringValue)
                } else if let doubleValue = try? stateArrayContainer.decode(Double.self) {
                    stateArray.append(doubleValue)
                } else if let intValue = try? stateArrayContainer.decode(Int.self) {
                    stateArray.append(intValue)
                } else if let boolValue = try? stateArrayContainer.decode(Bool.self) {
                    stateArray.append(boolValue)
                } else {
                    _ = try? stateArrayContainer.decode(AnyDecodable.self)
                }
            }
            tempStates.append(stateArray)
        }
        
        self.states = tempStates
    }

    init(states: [[Any]]) {
        self.states = states
    }
}

// Response structure for HexDB API
struct AircraftDetails: Decodable {
    let ICAOTypeCode: String
    let Manufacturer: String
    let RegisteredOwners: String
}

// Helper struct for decoding any type
struct AnyDecodable: Decodable {}
