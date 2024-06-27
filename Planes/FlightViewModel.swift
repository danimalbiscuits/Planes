import SwiftUI
import Combine

// ViewModel
class FlightViewModel: ObservableObject {
    @Published var flights: [Flight] = []

    private var cancellables = Set<AnyCancellable>()

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
                let newFlights = response.states.compactMap { state -> Flight? in
                    guard state.count > 6 else { return nil }
                    let icao24 = state[0] as? String ?? "Unknown"
                    let callsign = state[1] as? String ?? "Unknown"
                    let longitude = state[5] as? Double
                    let latitude = state[6] as? Double
                    return Flight(callsign: callsign, icao24: icao24, longitude: longitude, latitude: latitude)
                }
                DispatchQueue.main.async {
                    self.flights = newFlights
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
                    }
                })
                .store(in: &cancellables)
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
                    // Handle other types if needed
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
