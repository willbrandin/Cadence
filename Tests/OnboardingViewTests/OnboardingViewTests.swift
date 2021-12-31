import Combine
import ComposableArchitecture
import XCTest
import SnapshotTesting
import SwiftUI
import Models

@testable import OnboardingFeature

class OnboardingViewTests: XCTestCase {
    static override func setUp() {
        super.setUp()
        
        SnapshotTesting.diffTool = "ksdiff"
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
//        isRecording = true
    }
    
    override func tearDown() {
        isRecording = false
        
        super.tearDown()
    }
    
    func testOnboarding_Page1() {
        let store = Store(
            initialState: OnboardingState(tabIndex: 0),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        )
        
        var onBoardingView: some View {
            NavigationView {
                OnboardingPageView(
                    store: store
                )
                .navigationTitle("Cadence")
            }
        }
        
        assertSnapshot(
            matching: onBoardingView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
    
    func testOnboarding_Page2() {
        let store = Store(
            initialState: OnboardingState(tabIndex: 1),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        )
        
        var onBoardingView: some View {
            NavigationView {
                OnboardingPageView(
                    store: store
                )
                .navigationTitle("Cadence")
            }
        }
        
        assertSnapshot(
            matching: onBoardingView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
    
    func testOnboarding_AnimationGreat() {
        let store = Store(
            initialState: OnboardingState(
                mileageAnimation: .init(
                    width: 250,
                    animationDidStart: true,
                    mileageStatus: .great,
                    value: MileageStatus.great.animationValue
                ),
                tabIndex: 2
            ),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        )
        
        var onBoardingView: some View {
            NavigationView {
                OnboardingPageView(
                    store: store
                )
                .navigationTitle("Cadence")
            }
        }
        
        assertSnapshot(
            matching: onBoardingView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
    
    func testOnboarding_AnimationGood() {
        let store = Store(
            initialState: OnboardingState(
                mileageAnimation: .init(
                    width: 250,
                    animationDidStart: true,
                    mileageStatus: .good,
                    value: MileageStatus.good.animationValue
                ),
                tabIndex: 2
            ),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        )
        
        var onBoardingView: some View {
            NavigationView {
                OnboardingPageView(
                    store: store
                )
                .navigationTitle("Cadence")
            }
        }
        
        assertSnapshot(
            matching: onBoardingView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
    
    func testOnboarding_AnimationOkay() {
        let store = Store(
            initialState: OnboardingState(
                mileageAnimation: .init(
                    width: 250,
                    animationDidStart: true,
                    mileageStatus: .okay,
                    value: MileageStatus.okay.animationValue
                ),
                tabIndex: 2
            ),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        )
        
        var onBoardingView: some View {
            NavigationView {
                OnboardingPageView(
                    store: store
                )
                .navigationTitle("Cadence")
            }
        }
        
        assertSnapshot(
            matching: onBoardingView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
    
    func testOnboarding_AnimationRecommended() {
        let store = Store(
            initialState: OnboardingState(
                mileageAnimation: .init(
                    width: 250,
                    animationDidStart: true,
                    mileageStatus: .maintenanceRecommended,
                    value: MileageStatus.maintenanceRecommended.animationValue
                ),
                tabIndex: 2
            ),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        )
        
        var onBoardingView: some View {
            NavigationView {
                OnboardingPageView(
                    store: store
                )
                .navigationTitle("Cadence")
            }
        }
        
        assertSnapshot(
            matching: onBoardingView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
    
    func testOnboarding_AnimationNeeded() {
        let store = Store(
            initialState: OnboardingState(
                mileageAnimation: .init(
                    width: 250,
                    animationDidStart: true,
                    mileageStatus: .maintenceNeeded,
                    value: MileageStatus.maintenceNeeded.animationValue
                ),
                tabIndex: 2
            ),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        )
        
        var onBoardingView: some View {
            NavigationView {
                OnboardingPageView(
                    store: store
                )
                .navigationTitle("Cadence")
            }
        }
        
        assertSnapshot(
            matching: onBoardingView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
}
