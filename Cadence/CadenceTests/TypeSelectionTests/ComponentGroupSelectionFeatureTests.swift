import Combine
import ComposableArchitecture
import XCTest

@testable import Cadence

class ComponentGroupSelectionFeatureTests: XCTestCase {
    func testComponentGroupSelection() {
        let store = TestStore(
            initialState: ComponentGroupSelectionState(
                selectedComponentType: nil,
                components: ComponentGroup.allCases
            ),
            reducer: componentGroupSelectionReducer,
            environment: ComponentGroupSelectionEnvironment()
        )
        
        store.send(.didSelect(.brakes)) {
            $0.selectedComponentType = .brakes
        }
    }
}
