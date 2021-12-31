import Combine
import ComposableArchitecture
import XCTest
import Models

@testable import TypeSelectionFeature

class ComponentGroupSelectionFeatureTests: XCTestCase {
    func testComponentGroupSelection() {
        let store = TestStore(
            initialState: ComponentGroupSelectionState(
                selectedComponentType: nil
            ),
            reducer: componentGroupSelectionReducer,
            environment: ComponentGroupSelectionEnvironment()
        )
        
        store.send(.set(\.$selectedComponentGroupType, .brakes)) {
            $0.selectedComponentGroupType = .brakes
        }
    }
}
