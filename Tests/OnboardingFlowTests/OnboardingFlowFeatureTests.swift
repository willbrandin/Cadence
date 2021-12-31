import Combine
import ComposableArchitecture
import XCTest

@testable import OnboardingFeature

class OnboardingFlowFeatureTests: XCTestCase {
    func testOnboardingPageFlow() {        
        let store = TestStore(
            initialState: OnboardingState(),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        )
        
        store.send(.changeTabIndex(index: 0)) {
            $0.tabIndex = 0
        }
        
        store.send(.changeTabIndex(index: 1)) {
            $0.tabIndex = 1
        }
        
        store.send(.changeTabIndex(index: 2)) {
            $0.tabIndex = 2
        }
        
        store.send(.didLogin)
    }
}
