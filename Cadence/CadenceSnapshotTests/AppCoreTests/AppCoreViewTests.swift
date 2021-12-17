import Combine
import ComposableArchitecture
import XCTest
import SnapshotTesting

@testable import Cadence

class AppCoreViewTests: XCTestCase {
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

    func testLoggedIn_NoBikes() {
        assertSnapshot(
            matching: AppCoreView(
                store: Store(
                    initialState: AppCoreState(
                        onboardingFlowState: nil,
                        accountBikesState: .init(bikes: [])
                    ),
                reducer: .empty,
                environment: ()
            )
                                 ),
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
}
