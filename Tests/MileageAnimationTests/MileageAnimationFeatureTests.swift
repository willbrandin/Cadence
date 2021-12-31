import Combine
import ComposableArchitecture
import Models
import XCTest

@testable import OnboardingFeature

class MileageAnimationFeatureTests: XCTestCase {
    func testAnimation() {
        var environment = MileageAnimationEnvironment()
        
        let scheduler = DispatchQueue.test
        environment.mainQueue = scheduler.eraseToAnyScheduler()
        
        let store = TestStore(
            initialState: MileageAnimationState(),
            reducer: mileageAnimationReducer,
            environment: environment
        )
        
        store.send(.viewLoaded)
        scheduler.advance(by: 0.5)
        
        store.receive(.startAnimation) {
            $0.animationDidStart = true
            $0.value = MileageStatus.great.animationValue
        }
        
        scheduler.advance(by: 0.6)
        store.receive(.setStatus(.great)) {
            $0.mileageStatus = .great
            $0.value = MileageStatus.great.animationValue
        }
        
        scheduler.advance(by: 0.6)
        store.receive(.setStatus(.good)) {
            $0.mileageStatus = .good
            $0.value = MileageStatus.good.animationValue
        }
        
        scheduler.advance(by: 0.6)
        store.receive(.setStatus(.okay)) {
            $0.mileageStatus = .okay
            $0.value = MileageStatus.okay.animationValue
        }
        
        scheduler.advance(by: 0.6)
        store.receive(.setStatus(.maintenanceRecommended)) {
            $0.mileageStatus = .maintenanceRecommended
            $0.value = MileageStatus.maintenanceRecommended.animationValue
        }
        
        scheduler.advance(by: 0.6)
        store.receive(.setStatus(.maintenceNeeded)) {
            $0.mileageStatus = .maintenceNeeded
            $0.value = MileageStatus.maintenceNeeded.animationValue
        }
        
        scheduler.run()
    }
    
    func testNoAnimation_WhenLoaded() {
        let store = TestStore(
            initialState: MileageAnimationState(
                animationDidStart: true,
                mileageStatus: .maintenceNeeded,
                value: MileageStatus.maintenceNeeded.animationValue
            ),
            reducer: mileageAnimationReducer,
            environment: MileageAnimationEnvironment()
        )
        
        store.send(.viewLoaded) {
            $0.animationDidStart = true
            $0.mileageStatus = .maintenceNeeded
            $0.value = 1.0
        }
    }
}
