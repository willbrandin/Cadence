import Combine
import ComposableArchitecture
import XCTest

@testable import ComponentDetailFeature

class ComponentDetailFeatureTests: XCTestCase {
    func testComponentDetail_ShowingOptions() {
        let store = TestStore(
            initialState: ComponentDetailState(),
            reducer: componentDetailReducer,
            environment: .mocked
        )
        
        store.send(.toggleShowOptions(true)) {
            $0.isShowingOptions = true
        }
        
        store.send(.toggleShowOptions(false)) {
            $0.isShowingOptions = false
        }
        
        store.assert([
            .send(.replace),
            .send(.delete),
            .send(.edit)
        ])        
    }
}
