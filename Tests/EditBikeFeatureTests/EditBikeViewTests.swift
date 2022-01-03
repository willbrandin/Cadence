import Combine
import ComposableArchitecture
import Models
import XCTest
import World
import EditBikeFeature
import SwiftUI
import SnapshotTesting

class EditBikeViewTests: XCTestCase {
    
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
    
    func testEditBikeView() {
        let store = Store(
            initialState: EditBikeState(
                bike: .yetiMountain,
                isSaveBikeRequestInFlight: false,
                userSettings: .init()
            ),
            reducer: editBikeReducer,
            environment: EditBikeEnvironment(
                bikeClient: .failing,
                mainQueue: .failing
            )
        )
        
        var snapshotView: some View {
            EditBikeNavigationView(store: store)
        }
        
        assertSnapshot(
            matching: snapshotView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
}
