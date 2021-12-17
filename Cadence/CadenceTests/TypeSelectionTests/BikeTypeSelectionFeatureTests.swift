import Combine
import ComposableArchitecture
import XCTest

@testable import Cadence

class BikeTypeSelectionFeatureTests: XCTestCase {
    func testSelectedBike() {
        let store = TestStore(
            initialState: BikeTypeSelectionState(),
            reducer: bikeTypeSelectionReducer,
            environment: BikeTypeSelectionEnvironment()
        )
        
        store.send(.didSelect(.mountain)) {
            $0.selectedBikeType = .mountain
        }
        
        store.send(.didSelect(.commuter)) {
            $0.selectedBikeType = .commuter
        }
        
        store.send(.removeSelectedType) {
            $0.selectedBikeType = nil
        }
        
        store.send(.didSelect(.road)) {
            $0.selectedBikeType = .road
        }
    }
}
