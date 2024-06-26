import SwiftUI
import Combine

// ViewModel
class FlightViewModel: ObservableObject {
    @Published var flights: [Flight] = []

    private var cancellables = Set<AnyCancellable>()

    func fetchFlights() {
        let urlString = "https://opensky-network.org/api/states/all?lamin=-41.296381&lomin=174.388733&lamax=-40.737893&lomax=175.035553"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: OpenSkyResponse.self, decoder: JSONDecoder())
            .map { response in
                response.states.compactMap { stateArray in
                    if let callsign = stateArray[1] as? String,
                       let icao24 = stateArray[0] as? String,
                       !callsign.trimmingCharacters(in: .whitespaces).isEmpty {
                        return Flight(callsign: callsign.trimmingCharacters(in: .whitespaces), icao24: icao24)
                    }
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] flights in
                self?.flights = flights
                self?.fetchAircraftDetails()
            })
            .store(in: &cancellables)
    }

    private func fetchAircraftDetails() {
        let baseUrl = "https://hexdb.io/api/v1/aircraft/"

        flights.forEach { flight in
            let urlString = baseUrl + flight.icao24
            guard let url = URL(string: urlString) else { return }

            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: AircraftDetails.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] details in
                    if let index = self?.flights.firstIndex(where: { $0.id == flight.id }) {
                        self?.flights[index].ICAOTypeCode = details.ICAOTypeCode
                        self?.flights[index].Manufacturer = details.Manufacturer
                        self?.flights[index].RegisteredOwners = details.RegisteredOwners
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
}

// Response structure for HexDB API
struct AircraftDetails: Decodable {
    let ICAOTypeCode: String
    let Manufacturer: String
    let RegisteredOwners: String
}

// Helper struct for decoding any type
