import Combine
import ComposableArchitecture
import Models
import XCTest

@testable import TypeSelectionFeature

class ComponentTypeSelectionFeatureTests: XCTestCase {
    func testComponentTypeSelection() {
        let store = TestStore(
            initialState: ComponentTypeSelectionState(
                selectedComponentType: nil
            ),
            reducer: componentTypeSelectionReducer,
            environment: ComponentTypeSelectionEnvironment()
        )
        
        store.send(.set(\.$selectedComponentType, .derailleur)) {
            $0.selectedComponentType = .derailleur
        }
    }
}
