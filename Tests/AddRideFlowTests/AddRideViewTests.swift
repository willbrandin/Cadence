import Combine
import ComposableArchitecture
import Models
import XCTest
import World
import AddRideFlowFeature
import SwiftUI
import SnapshotTesting

class AddRideViewTests: XCTestCase {
    
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
    
    func testAddRideView() {
        let baseDate = Date.initFromComponents(year: 2022, month: 1, day: 15, hour: 8, minute: 0)!

        let store = Store(
            initialState: AddRideFlowState(
                selectableBikes: [.yetiMountain, .specializedMountain, .canyonRoad],
                selectedBike: .yetiMountain,
                miles: "45",
                date: baseDate,
                userSettings: .init()
            ),
            reducer: addRideReducer,
            environment: AddRideFlowEnvironment.failing
        )
        
        var snapshotView: some View {
            NavigationView {
                AddRideFlowRootView(store: store)
            }
        }
        
        assertSnapshot(
            matching: snapshotView,
            as: .image(layout: .device(config: .iPhoneXsMax))
        )
    }
}
