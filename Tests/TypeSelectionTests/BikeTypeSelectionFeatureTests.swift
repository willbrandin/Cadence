import Combine
import ComposableArchitecture
import XCTest
import Models

@testable import TypeSelectionFeature

class BikeTypeSelectionFeatureTests: XCTestCase {
    func testSelectedBike() {
        let store = TestStore(
            initialState: BikeTypeSelectionState(),
            reducer: bikeTypeSelectionReducer,
            environment: BikeTypeSelectionEnvironment()
        )
        
        store.send(.set(\.$selectedBikeType, .mountain)) {
            $0.selectedBikeType = .mountain
        }
        
        store.send(.set(\.$selectedBikeType, .commuter)) {
            $0.selectedBikeType = .commuter
        }
        
        store.send(.set(\.$selectedBikeType, .road)) {
            $0.selectedBikeType = .road
        }
    }
}
