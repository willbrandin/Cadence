import Combine
import ComposableArchitecture
import XCTest

@testable import Cadence

class ComponentTypeSelectionFeatureTests: XCTestCase {
    func testComponentTypeSelection() {
        let store = TestStore(
            initialState: ComponentTypeSelectionState(
                selectedComponentType: nil,
                components: ComponentType.allCases
            ),
            reducer: componentTypeSelectionReducer,
            environment: ComponentTypeSelectionEnvironment()
        )
        
        store.send(.didSelect(.derailleur)) {
            $0.selectedComponentType = .derailleur
        }
    }
}
